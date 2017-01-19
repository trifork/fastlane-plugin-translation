module Fastlane
  module Actions
    class TranslationAction < Action

      require 'google_drive'
      require 'csv'

      def self.run(params)
        UI.message "Logging into google using #{params[:config_path]}"
        session = GoogleDrive::Session.from_config(params[:config_path])

        UI.message "Downloading CVS to #{params[:cvs_output_path]}"
        file = session.file_by_id(params[:doc_id])
        file.export_as_file(params[:cvs_output_path], "text/csv")

        if params[:ios_output_paths]
          self.convert_CVS_to_iOS_paths(params[:key], params[:cvs_output_path], params[:ios_output_paths])
        end

        if params[:android_output_paths]
          convert_CVS_to_android_paths(params[:key], params[:cvs_output_path], params[:android_output_paths])
        end

        if params[:swift_struct_path]
          self.create_swift_struct(params[:key], params[:ios_output_paths].values.first, params[:cvs_output_path], params[:swift_struct_path])
        end

        if params[:dotnet_class_path]
           self.create_dotnet_class(params[:key], params[:cvs_output_path], params[:dotnet_class_path])
        end

        File.delete(params[:cvs_output_path])
      end

      def self.convert_CVS_to_iOS_paths(key, cvs_path, output_paths)
        output_paths.each{|file_path, index|
          FileUtils.mkdir_p(File.dirname(file_path))
          UI.message("Writing #{file_path}")
          file = open(file_path, 'w')
          CSV.foreach(cvs_path) do |row|
            if row[key] && row[key].length > 0 && row[index] != nil
              keyRow = row[key]
              valueRow = row[index].gsub("\"", "\\\"")
              valueRow = valueRow.gsub("\n", "\\n")
              file.write("#{keyRow} = \"#{valueRow}\";\n")
            end
          end
          file.close()
        }
      end

      def self.convert_CVS_to_android_paths(key, cvs_path, output_paths)
        output_paths.each{|file_path, index|
          FileUtils.mkdir_p(File.dirname(file_path))
          UI.message("Writing #{file_path}")
          file = open(file_path, 'w')
          file.write("<resources>\n")
          CSV.foreach(cvs_path) do |row|
            if row[key] && row[key].length > 0
              keyRow = row[key]
              file.write("\t<string name=\"#{keyRow}\">#{row[index]}</string>\n")
            end
          end
          file.write('</resources>')
          file.close()
        }
      end

      def self.create_swift_struct(key, master_index, cvs_path, swift_path)
        UI.message("Writing swift struct #{swift_path}")
        FileUtils.mkdir_p(File.dirname(swift_path))
        file = open(swift_path, 'w')
        file.write("import Foundation\nstruct Translations {\n")

        CSV.foreach(cvs_path) do |row|
          if row[key] && row[key].length > 0 && row.compact.length > 1
            keyRow = row[key]
            master = row[master_index]
            parameters = master.scan(/\%\d+/)
            if parameters.count > 0
              args_str = parameters.map { |e| e.sub('%', 'p') + ': String' }.join(', _ ')
              file.write("\tstatic func #{keyRow}(_ #{args_str}) -> String {")
              file.write(" return NSLocalizedString(\"#{keyRow}\", comment: \"\")")
              parameters.each{|e| file.write(".replacingOccurrences(of: \"#{e}\", with: #{e.sub('%', 'p')})")}
              file.write(" }\n")
            else
              file.write("\tstatic let #{keyRow} = NSLocalizedString(\"#{keyRow}\", comment: \"\");\n")
            end
          end
        end
        file.write("}")
        file.close()
      end

      def self.create_dotnet_class(key, cvs_path, dotnet_path)
        UI.message("Writing dotnet struct #{dotnet_path}")
        FileUtils.mkdir_p(File.dirname(dotnet_path))
        file = open(dotnet_path, 'w')
        file.write("using Foundation;\nstatic class Translations {\n")

        CSV.foreach(cvs_path) do |row|
          if row[key] && row[key].length > 0
            keyRow = row[key]
            file.write("\tpublic static string #{keyRow} { get { return NSBundle.MainBundle.LocalizedString (\"#{keyRow}\", null); } }\n")
          end
        end
        file.write("}")
        file.close()
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Output translations from Google sheet into templates."
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
                                       description: "refrence for the config json file, see https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md for more info",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :doc_id,
                                       env_name: "FL_TRANSLATION_DOC_ID",
                                       description: "id of the google sheet, can be used instead of doc_name after creation",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :cvs_output_path,
                                       default_value: FastlaneCore::FastlaneFolder.path + "translation.cvs",
                                       env_name: "FL_TRANSLATION_CVS_OUTPUT_PATH",
                                       description: "The path where the cvs is placed",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ios_output_paths,
                                       default_value: nil,
                                       env_name: "FL_TRANSLATION_IOS_OUTPUT_PATH",
                                       is_string: false,
                                       description: "An map from path to a column in the google sheet outputs a localized .strings file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :android_output_paths,
                                       default_value: nil,
                                       env_name: "FL_TRANSLATION_ANDROID_OUTPUT_PATH",
                                       is_string: false,
                                       description: "An map from path to a column in the google sheet outputs a strings.xml",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :swift_struct_path,
                                       default_value: nil,
                                       env_name: "FL_TRANSLATION_SWIFT_STRUCT_PATH",
                                       is_string: false,
                                       description: "Creates a swift struct with all the translations as properties",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :dotnet_class_path,
                                       default_value: nil,
                                       env_name: "FL_TRANSLATION_DOTNET_CLASS_PATH",
                                       is_string: false,
                                       description: "Creates a .net class with all the translations as properties",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :key,
                                       default_value: 1,
                                       is_string: false,
                                       env_name: "FL_TRANSLATION_KEY",
                                       description: "index of key column",
                                       optional: true)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
