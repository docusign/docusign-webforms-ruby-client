require "docusign_webforms"
require "base64"
require "uri"
require "date"


describe "DocuSign Ruby Client Tests" do
  def login
    begin
      if $api_client.nil?
        configuration = DocuSign_WebForms::Configuration.new
        configuration.host = $host

        $api_client = DocuSign_WebForms::ApiClient.new(configuration)
        $api_client.set_oauth_base_path(DocuSign_WebForms::OAuth::DEMO_OAUTH_BASE_PATH)
      end

      decode_base64_content = Base64.decode64(ENV["PRIVATE_KEY"])

      File.open($private_key_filename, "wb") do |f|
        f.write(decode_base64_content)
      end
      scopes = [DocuSign_WebForms::OAuth::SCOPE_IMPERSONATION, DocuSign_WebForms::OAuth::SCOPE_SIGNATURE, "webforms_read", "webforms_instance_read", "webforms_instance_write"]
      token_obj = $api_client.request_jwt_user_token(ENV["INTEGRATOR_KEY_JWT"], ENV["USER_ID"], File.read($private_key_filename), $expires_in_seconds, scopes)
      user_info = $api_client.get_user_info(token_obj.access_token)

      if !user_info.nil?
        user_info.accounts.each do |account|
          if account.is_default == "true"
            account_id = account.account_id
            $api_client.set_base_path("https://apps-d.docusign.com/api/webforms")
            return account
          end
        end
      end
    rescue => e
      puts "Error during processing: #{$!}"
    end

    return nil
  end

  def create_api_client
    if $api_client.nil?
      self.login()
    end

    return $api_client
  end

  before(:all) do
    # run before each test
    $host = "apps-d.docusign.com"

    $expires_in_seconds = 3600 #1 hour
    $auth_server = "account-d.docusign.com"
    $private_key_filename = "../docs/private.pem"

    $recipient_name = "Ruby SDK"

    # Required for embedded signing url
    $client_user_id = ENV["USER_ID"]
    $integrator_key = ENV["INTEGRATOR_KEY_JWT"]
    $secret = ENV["SECRET"]
    $return_url = "https://developers.docusign.com/"
    $authentication_method = "email"

    $template_id = ""

    $base_uri = nil
    $account_id = nil
    $api_client = nil
    $form_id = nil
    $client_user_id = nil
    $instance_id = nil
    login()
  end

  after do
    # run after each test
  end

  describe DocuSign_WebForms::OAuth do
    describe ".login" do
      context "given correct credentials" do
        it "return Account" do
          account = login()

          if !account.nil?
            $base_uri = "https://apps-d.docusign.com/api/webforms"
            $account_id = account.account_id
          end

          expect($account_id).to be_truthy
        end
      end
    end
  end

  describe DocuSign_WebForms::FormManagementApi do

    describe ".ListForms" do
      context "given account id" do
        it "return forms" do
          api_client = create_api_client()
          form_management = DocuSign_WebForms::FormManagementApi.new(api_client)
          list_forms = form_management.list_forms($account_id)

          # Ensure that the response from list_forms is correctly structured
          if list_forms.is_a?(DocuSign_WebForms::WebFormSummaryList)
            web_form_summary_list = list_forms

            # Check if there are items in the list
            if web_form_summary_list.items.any?
              web_form_summary_list.items.each do |web_form_summary|
                expect(web_form_summary.id).to be_truthy
                expect(web_form_summary.account_id).to be_truthy
                expect(web_form_summary.is_published).not_to be_nil
                expect(web_form_summary.is_enabled).not_to be_nil
                if web_form_summary.is_enabled == true
                  $form_id = web_form_summary.id
                  break # Exit loop once the first enabled form is found
                end
              end
            else
              puts "No web form summaries found."
            end
          else
            puts "Error: Unexpected response format from list_forms."
          end
          expect(list_forms).to be_truthy
        end
      end
    end
    describe ".GetForm" do
      context "given account id and form id" do
        it "return form" do
          api_client = create_api_client()
          form_management = DocuSign_WebForms::FormManagementApi.new(api_client)
          form_options = DocuSign_WebForms::GetFormOptions.new
          form_options.state = "active"
          get_form = form_management.get_form($account_id, $form_id, form_options)
          # Ensure that the response from list_forms is correctly structured
          if get_form.is_a?(DocuSign_WebForms::WebForm)
            web_form = get_form

            expect(web_form.id).to be_truthy
            expect(web_form.id).to eq ($form_id)
            expect(web_form.account_id).to be_truthy
            expect(web_form.account_id).to eq($account_id)
            expect(web_form.is_published).not_to be_nil
            expect(web_form.is_enabled).not_to be_nil
            expect(web_form.form_state).not_to be_nil
            expect(web_form.form_metadata).not_to be_nil
          else
            puts "Error: Unexpected response format from get_form."
            pending "There is error in the API data"
          end
          expect(get_form).to be_truthy
        end
      end
    end

    # Negative testing
    describe ".ListForms" do
      context "given wrong account id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_management = DocuSign_WebForms::FormManagementApi.new(api_client)
          wrong_account_id = "abc123"
          expect {
            list_forms = form_management.list_forms(wrong_account_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
    end

    describe ".GetForm" do
      context "given  wrong account id and wrong form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_management = DocuSign_WebForms::FormManagementApi.new(api_client)
          wrong_account_id = "abc123"
          wrong_form_id = "xyz123"
          expect {
            get_form = form_management.get_form(wrong_account_id, wrong_form_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given correct account id and wrong form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_management = DocuSign_WebForms::FormManagementApi.new(api_client)
          wrong_form_id = "xyz123"
          expect {
            get_form = form_management.get_form($account_id, wrong_form_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given wrong account id and correct form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_management = DocuSign_WebForms::FormManagementApi.new(api_client)
          wrong_account_id = "abc123"
          expect {
            get_form = form_management.get_form(wrong_account_id, $form_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
    end

  end

  describe DocuSign_WebForms::FormInstanceManagementApi do

    describe ".CreateInstance" do
      context "given account id, form id, and instance body" do
        it "creates instance" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          instance_body = DocuSign_WebForms::CreateInstanceRequestBody.new
          now = DateTime.now
          client_id = "asif.sajjad-#{now}"
          $client_user_id = client_id
          instance_body.client_user_id = client_id
          instance_body.tags = ["general_details"]
          form_instance = form_instance_management.create_instance($account_id, $form_id, instance_body)

          # Ensure that the response from list_forms is correctly structured
          if form_instance.is_a?(DocuSign_WebForms::WebFormInstance)
            web_form_instance = form_instance
            $instance_id = web_form_instance.id
            expect(web_form_instance.id).to be_truthy
            expect(web_form_instance.form_id).to eq ($form_id)
            expect(web_form_instance.account_id).to be_truthy
            expect(web_form_instance.account_id).to eq($account_id)
            expect(web_form_instance.form_url).not_to be_nil
            expect(web_form_instance.instance_token).not_to be_nil
            expect(web_form_instance.token_expiration_date_time).not_to be_nil
          else
            puts "Error: Unexpected response format from form_instance."
            pending "Unexpected response in create form_instance other than WebformInstance"
          end
          expect(form_instance).to be_truthy
        end
      end
    end

    describe ".GetInstance" do
      context "given account id, form id, and instance id" do
        it "get instance" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          form_instance = form_instance_management.get_instance($account_id, $form_id, $instance_id)

          # Ensure that the response from list_forms is correctly structured
          if form_instance.is_a?(DocuSign_WebForms::WebFormInstance)
            web_form_instance = form_instance
            expect(web_form_instance.id).to be_truthy
            expect(web_form_instance.form_id).to eq ($form_id)
            expect(web_form_instance.account_id).to be_truthy
            expect(web_form_instance.status).to be_truthy
            expect(web_form_instance.account_id).to eq($account_id)
            expect(web_form_instance.client_user_id).to eq($client_user_id)
            expect(web_form_instance.instance_metadata).not_to be_nil
          else
            puts "Error: Unexpected response format from get_instance."
            pending "Unexpected response in get_instance other than WebformInstance"
          end
          expect(form_instance).to be_truthy
        end
      end
    end

    describe ".ListInstances" do
      context "given account id and form id" do
        it "fetch instances" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          form_instances_object = form_instance_management.list_instances($account_id, $form_id)
            if form_instances_object.is_a?(DocuSign_WebForms::WebFormInstanceList)
              form_instances = form_instances_object.items
                # Ensure that the response from list_forms is correctly structured
              if form_instances.is_a?(Array) && form_instances.all? { |item| item.is_a?(DocuSign_WebForms::WebFormInstance) }
                web_form_instances = form_instances
                web_form_instance = web_form_instances.first
                expect(web_form_instance.id).to be_truthy
                expect(web_form_instance.form_id).to eq ($form_id)
                expect(web_form_instance.account_id).to be_truthy
                expect(web_form_instance.status).to be_truthy
                expect(web_form_instance.account_id).to eq($account_id)
                expect(web_form_instance.instance_metadata).not_to be_nil
              else
                puts "Error: Unexpected response format from list_instances."
                pending "Unexpected item in list form_instances other than WebformInstance"
              end
          else
            puts "Error: Unexpected response format from list_instances_object."
              pending "Unexpected response in form_instances_object other than WebformInstanceList"
          end
          expect(form_instances_object).to be_truthy
        end
      end
    end

    describe ".RefreshToken" do
      context "given account id, form id, and instance id" do
        it "refresh the token" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          refresh_token = form_instance_management.refresh_token($account_id, $form_id, $instance_id)

          # Ensure that the response from list_forms is correctly structured
          if refresh_token.is_a?(DocuSign_WebForms::WebFormInstance)
            web_form_instance = refresh_token
            expect(web_form_instance.id).to be_truthy
            expect(web_form_instance.id).to eq ($instance_id)
            expect(web_form_instance.instance_token).to be_truthy
            expect(web_form_instance.form_url).to be_truthy
            expect(web_form_instance.token_expiration_date_time).to be_truthy
          else
            puts "Error: Unexpected response format from refresh_token."
          end
          expect(refresh_token).to be_truthy
        end
      end
    end

    # Negative testing
    describe ".CreateInstance" do
      context "given wrong account id with correct form id, and instance body" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          instance_body = DocuSign_WebForms::CreateInstanceRequestBody.new
          now = DateTime.now
          client_id = "asif.sajjad-#{now}"
          instance_body.client_user_id = client_id
          instance_body.tags = ["general_details"]
          wrong_account_id = "abc123"

          expect{
            form_instance = form_instance_management.create_instance(wrong_account_id, $form_id, instance_body)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given right account id and instance body with wrong form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          instance_body = DocuSign_WebForms::CreateInstanceRequestBody.new
          now = DateTime.now
          client_id = "asif.sajjad-#{now}"
          instance_body.client_user_id = client_id
          instance_body.tags = ["general_details"]
          wrong_form_id = "xyz123"

          expect{
            form_instance = form_instance_management.create_instance($account_id, wrong_form_id, instance_body)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given right account id and form id with nil instance body" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          instance_body = nil

          expect{
            form_instance = form_instance_management.create_instance($account_id, $form_id, instance_body)
          }.to raise_error(ArgumentError)
        end
      end
      context "given nil account id with correct form id and instance body" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          instance_body = DocuSign_WebForms::CreateInstanceRequestBody.new
          now = DateTime.now
          client_id = "asif.sajjad-#{now}"
          instance_body.client_user_id = client_id
          instance_body.tags = ["general_details"]

          expect{
            form_instance = form_instance_management.create_instance(nil, $form_id, instance_body)
          }.to raise_error(ArgumentError)
        end
      end
      context "given nil form id with correct account id and instance body" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          instance_body = DocuSign_WebForms::CreateInstanceRequestBody.new
          now = DateTime.now
          client_id = "asif.sajjad-#{now}"
          instance_body.client_user_id = client_id
          instance_body.tags = ["general_details"]

          expect{
            form_instance = form_instance_management.create_instance($account_id, nil, instance_body)
          }.to raise_error(ArgumentError)
        end
      end
    end


    describe ".GetInstance" do
      context "given wrong account id with correct form id, and instance id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          wrong_account_id = "abc123"
          expect{
            form_instance = form_instance_management.get_instance(wrong_account_id, $form_id, $instance_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given wrong form id with correct account id, and instance id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          wrong_form_id = "xyz123"
          expect{
            form_instance = form_instance_management.get_instance($account_id, wrong_form_id, $instance_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given wrong instance id with correct account id, and form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          wrong_instance_id = "lmn123"
          expect{
            form_instance = form_instance_management.get_instance($account_id, $form_id, wrong_instance_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given nil instance id with correct account id, and form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          expect{
            form_instance = form_instance_management.get_instance($account_id, $form_id, nil)
          }.to raise_error(ArgumentError)
        end
      end
      context "given nil account id with correct form id, and instance id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          expect{
            form_instance = form_instance_management.get_instance(nil, $form_id, $instance_id)
          }.to raise_error(ArgumentError)
        end
      end
      context "given nil form id with correct account id, and instance id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          expect{
            form_instance = form_instance_management.get_instance($account_id, nil, $instance_id)
          }.to raise_error(ArgumentError)
        end
      end

    end


    describe ".ListInstances" do
      context "given wrong account id and correct form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          wrong_account_id = "abc123"
          expect{
            form_instances = form_instance_management.list_instances(wrong_account_id, $form_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given wrong form id and correct account id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          wrong_form_id = "xyz123"
          expect{
            form_instances = form_instance_management.list_instances($account_id, wrong_form_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given nil form id and correct account id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          expect{
            form_instances = form_instance_management.list_instances($account_id, nil)
          }.to raise_error(ArgumentError)
        end
      end
      context "given nil account id and correct form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          expect{
            form_instances = form_instance_management.list_instances(nil, $form_id)
          }.to raise_error(ArgumentError)
        end
      end
    end


    describe ".RefreshToken" do
      context "given wrong account id with correct form id, and instance id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          wrong_account_id = "abc123"
          expect{
            refresh_token = form_instance_management.refresh_token(wrong_account_id, $form_id, $instance_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given wrong form id with correct account id, and instance id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          wrong_form_id = "xyz123"
          expect{
            refresh_token = form_instance_management.refresh_token($account_id, wrong_form_id, $instance_id)
          }.to raise_error(DocuSign_WebForms::ApiError)
        end
      end
      context "given nil account id with correct form id, and instance id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          expect{
            refresh_token = form_instance_management.refresh_token(nil, $form_id, $instance_id)
          }.to raise_error(ArgumentError)
        end
      end
      context "given nil form id with correct account id, and instance id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          expect{
            refresh_token = form_instance_management.refresh_token($account_id, nil, $instance_id)
          }.to raise_error(ArgumentError)
        end
      end
      context "given nil instance id with correct account id, and form id" do
        it "should throw API Error" do
          api_client = create_api_client()
          form_instance_management = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
          expect{
            refresh_token = form_instance_management.refresh_token($account_id, $form_id, nil)
          }.to raise_error(ArgumentError)
        end
      end
    end

  end

end
