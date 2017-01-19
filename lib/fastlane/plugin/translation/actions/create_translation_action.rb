module Fastlane
  module Actions
    class CreateTranslationAction < Action

      require 'google_drive'

      def self.run(params)
        UI.message "Logging into google using #{params[:config_path]}"
        session = GoogleDrive::Session.from_config(params[:config_path])

        UI.message "Creating document with title '#{params[:doc_name]}'"

        file = session.spreadsheet_by_title(params[:doc_name])
        if(file)
          raise "Document already exists, please change to a different doc_name".red
        else
          tmp_file = "#{FastlaneCore::FastlaneFolder.path}/translations"
          f = File.open(tmp_file, "w")
          f.close()
          file = session.upload_from_file("#{File.absolute_path(tmp_file)}", params[:doc_name], :convert => true, :content_type => "text/csv")

          File.delete(tmp_file)

          file.acl.push({:type => 'user', :value => params[:owner_email], :role => 'owner'})
          file.acl.push({:type => 'user', :value => params[:seed_email], :role => 'writer'}) unless params[:owner_email] == params[:seed_email]
          UI.message "Done creating document, use doc_id:'#{file.id}' for pulling translations.".yellow
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Create sheet for translations in Google sheets."
      end

      def self.authors
        ["Krzysztof Piatkowski", "Jakob Jensen"]
      end

      def self.return_value
      end

      def self.details
        nil
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :config_path,
                                       env_name: "FL_TRANSLATION_CONFIG_PATH",
                                       description: "reference for the config json file, see https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md for more info",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :doc_name,
                                       env_name: "FL_TRANSLATION_DOC_NAME",
                                       description: "unique name of the google sheet",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :owner_email,
                                       env_name: "FL_TRANSLATION_OWNER_EMAIL",
                                       description: "The mail to give ownership over the the document",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :seed_email,
                                       env_name: "FL_TRANSLATION_SEED_EMAIL",
                                       description: "The mail to give rights when initializing the document",
                                       optional: false),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
