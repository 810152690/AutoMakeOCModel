require 'rubygems'
require './FileManager'
require './MakeOCClass'

@generator = Generator.new

# 读取json文件
fileManager = FileManager.new
obj = fileManager.readJSONContentFromFile('input.json')
keys = obj.keys
values = obj.values

puts "Enter className"
className = gets

className = className.delete("\n")

# 设置类名
@generator.setClassInfo(className, keys, values)

hContent = @generator.createHeaderFileContent
mContent = @generator.createMFileContent

# 写入转换后的内容
fileManager.writeContentToFile(hContent, "./", "#{className}.h")
fileManager.writeContentToFile(mContent, "./", "#{className}.m")




