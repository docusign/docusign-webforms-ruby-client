require 'docusign_webforms'
require 'base64'
require 'uri'
RSpec.describe DocuSign_WebForms::FormManagementApi do
    def login
        begin
            if $api_client.nil?
                configuration = DocuSign_WebForms::Configuration.new
                configuration.host = "https://demo.services.docusign.net/webforms/v1.1"

                $api_client = DocuSign_WebForms::ApiClient.new(configuration)
            end

            $api_client.set_default_header("Authorization", "Bearer" + " " + "")
            return nil
        end
    end
    
    def create_api_client
    if $api_client.nil?
        self.login()
    end

    return $api_client
    end

    describe '#listForms' do
        it 'list forms' do
            begin
                api_client = create_api_client()
                form_management_api = DocuSign_WebForms::FormManagementApi.new(api_client)
                puts form_management_api.list_forms("3c9c0391-01ac-4a98-8fab-adb9d0e548d2")
            rescue => e
                puts "An error occurred: #{e}"
            end
        end  
    end
end
