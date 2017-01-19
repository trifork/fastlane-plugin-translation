module Fastlane
  module Helper
    class TranslationHelper
      # class methods that you define here become available in your action
      # as `Helper::TranslationsHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the translation plugin helper!")
      end
    end
  end
end
