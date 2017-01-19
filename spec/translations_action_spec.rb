describe Fastlane::Actions::TranslationAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The translation plugin is working!")

      Fastlane::Actions::TranslationAction.run(nil)
    end
  end
end
