module NanoBox
  class Prepare

    def existing_files(filepath)
      files = []

      if filepath.is_a?(String)
        filepath=[filepath]
      end

      filepath.each do |file|
        if File.exist?("/code/#{file}")
          files << file
        end
      end

      return files
    end
    
  end
end