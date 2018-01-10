require 'json'

class FileManager
	def readJSONContentFromFile(filePath)
		content = File.read(filePath)
		jsonContent = JSON.parse(content)
		return jsonContent
	end

	def writeContentToFile(content, filePath, fileName)
		aFile = File.new(File.join(filePath, fileName), "w+")
		if aFile
   			aFile.syswrite(content)
		else
  		 	puts "Unable to open file!"
		end
	end
end