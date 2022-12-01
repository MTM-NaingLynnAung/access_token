require 'facebookbusiness'
require 'csv'
class LinkageRepository
  class << self
    def view
      ExternalServiceDefinition.all
    end

    def find_params_definition(definition)
      ExternalServiceParameterDefinition.where(external_service_definition_id: definition)
    end

    def store(current_user, session, crypt, credentials, params, id, redirect_uri)
      access_token = FacebookApiGateway.get_access_token(credentials, params, redirect_uri)
      session[:"#{id}"] = access_token.token
      linkage = LinkageSystem.create!(
        label: session[:label],
        created_by: current_user.id,
        updated_by: current_user.id
      )
      external_service = ExternalService.create!(
        linkage_system_id: linkage.id,
        external_service_definition_id: session[:definition],
        created_by: current_user.id,
        updated_by: current_user.id
      )
      external_service_parameter_definition = LinkageRepository.find_params_definition(session[:definition])
      external_service_parameter_definition.each do |parameter_definition|
        external_service.external_service_parameters.create!(
          external_service_id: external_service.id,
          external_service_parameter_definition_id: parameter_definition.id,
          parameter_value: parameter_definition.is_encrypted == 0 ? session[:"#{parameter_definition.id}"] : crypt.encrypt_and_sign(session[:"#{parameter_definition.id}"])
        )
      end
    end

    def list(params)
      ExternalService.where(external_service_definition_id: params)
    end

    def service_name(id)
      ExternalServiceDefinition.find_by(id: id)
    end

    def find_external_service(id)
      ExternalService.find_by(linkage_system_id: id)
    end

    def update(external_service, crypt, exist_params, input_params, params)
      external_service.external_service_parameters.each do |params_value|
        next unless params_value.external_service_parameter_definition.is_displayed != 0

        decrypt_data = params_value.external_service_parameter_definition.is_encrypted == 0 ? params_value.external_service_parameter_definition.external_service_parameter.parameter_value : crypt.decrypt_and_verify(params_value.external_service_parameter_definition.external_service_parameter.parameter_value)
        exist_params << decrypt_data
        input_params << params[:"#{params_value.external_service_parameter_definition.id}"]
      end
    end

    def update_label(external_service, label)
      external_service.linkage_system.update(label: label)
    end

    def change(credentials, params, redirect_uri, id, session, crypt)
      access_token = FacebookApiGateway.get_access_token(credentials, params, redirect_uri)
      session[:"#{id}"] = access_token.token
      external_service = LinkageRepository.find_external_service(session[:linkage_id])
      LinkageRepository.update_label(external_service, session[:label])
      external_service.external_service_parameters.each do |params_value|
        params_value.update(
          parameter_value: params_value.external_service_parameter_definition.is_encrypted == 0 ? session[:"#{params_value.external_service_parameter_definition.id}"] : crypt.encrypt_and_sign(session[:"#{params_value.external_service_parameter_definition.id}"])
        )
      end
    end

    def delete(linkage)
      linkage.destroy
    end

    def get_credentials(credentials, external_service, crypt)
      external_service.external_service_parameters.each do |current_value|
        credentials << if current_value.external_service_parameter_definition.is_encrypted == 0
                         current_value.parameter_value
                       else
                         crypt.decrypt_and_verify(current_value.parameter_value)
                       end
      end
    end

    def audience_create(params, credentials, subtype, description, customer_file_source, external_service)
      ad_account = FacebookAds::AdAccount.get("act_#{params[:ad_id]}",
                                              { access_token: credentials[2], app_secret: credentials[1] })
      customaudiences = ad_account.customaudiences.create({
                                                            name: params[:name],
                                                            subtype: subtype,
                                                            description: description,
                                                            customer_file_source: customer_file_source
                                                          })
      service_report = ExternalServiceAvailableReport.create({
                                                               external_service_id: external_service.id,
                                                               service_type: external_service.external_service_definition_id,
                                                               name: params[:name],
                                                               identifier: params[:name],
                                                               fetched_at: Time.now,
                                                               custom_audience_id: customaudiences.id
                                                             })
    end

    def audience_update(params, credentials)
      custom_audience = FacebookAds::CustomAudience.get(params[:ad_id],
                                                        { access_token: credentials[2], app_secret: credentials[1] })
      custom_audience.name = params[:name]
      custom_audience.save
      service_report = ExternalServiceAvailableReport.find_by(external_service_id: params[:id])
      service_report.update(
        name: params[:name],
        identifier: params[:name],
        custom_audience_id: params[:ad_id]
      )
    end

    def audience_user_create(file, external_service, crypt, service_report)
      email = []
      credentials = []
      file = File.open(file)
      csv = CSV.read(file)
      csv.shift
      csv.each do |row|
        email << Digest::SHA256.hexdigest(row[0])
      end

      LinkageRepository.get_credentials(credentials, external_service, crypt)

      custom_audience = FacebookAds::CustomAudience.get(service_report.custom_audience_id,
                                                        { access_token: credentials[2], app_secret: credentials[1] })
      payload = { schema: 'EMAIL_SHA256', data: email }
      deleted_user = custom_audience.users.destroy(payload: payload.to_json)
      created_user = custom_audience.users.create(payload: payload.to_json)
      response = { deleted_user: deleted_user, created_user: created_user }
    end

    def find_service_report(id)
      ExternalServiceAvailableReport.find_by(external_service_id: id)
    end
  end
end
