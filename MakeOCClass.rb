module StringNumber
	def is_number?
    	true if Float(self) rescue false
  	end
end

class Property
	attr_accessor :name
	attr_accessor :type
	attr_accessor :relation_type
	attr_accessor :auto_type
	attr_accessor :containerPropertyClassName#容器里面类名

	def initialize
		yield self if block_given?
	end

	def property_declare_str
		"@property(#{auto_type}, #{relation_type}) #{type} *#{name};"
	end

	def property_encode_str
		"[aCoder encodeObject:self.#{name} forKey:NSStringFromSelector(@selector(#{name}));"
	end

	def property_decode_str
		"self.#{name} = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(#{name}))];"
	end
end

class OCClass
	attr_accessor :className
	attr_accessor :propertyies
	attr_accessor :propertyDemoValues
	attr_accessor :relateClasses

	def initialize (className, keys, values)
		yield self if block_given?
		#初始化变量
		self.propertyies = []
		self.propertyDemoValues = values
		self.relateClasses = []
		self.className = className
		self.createProperties(keys)
	end

	def addProperty(p)
		self.propertyies << p
	end

	def modelContainerPropertyGenericClass#容器中类名
		declare = ""

		for i in 0...self.propertyies.length
			property = self.propertyies[i]
			if property.type == "NSArray"
				if declare.empty?
					declare << "+ (NSDictionary *)modelContainerPropertyGenericClass {\n	return @{"
				end
				declare << " #{property.name} : [#{property.containerPropertyClassName} class]" 

				if i != self.propertyies.length-1
					declare << ", "
				end
			end
		end
		if !declare.empty?
			declare << "};\n}"
		end
		return declare
	end

	#h文件
	def createHFileContent
		className = self.className.delete("\n")

		s = ""
		for i in 0...self.relateClasses.length
			relateClass = self.relateClasses[i]
			s << relateClass.createHFileContent
		end

		s << "@interface #{className} : NSObject \n"

		self.propertyies.each do |property|
			s << property.property_declare_str
			s << "\n"
		end

		s << "@end\n\n"
		return s
	end

	#m文件
	def createMFileContent
		className = self.className.delete("\n")

		content = ""
		for i in 0...self.relateClasses.length
			relateClass = self.relateClasses[i]
			content << relateClass.createMFileContent

		end

		content << "@implementation #{className} \n\n\n"

		content << "#{self.modelContainerPropertyGenericClass}\n\n"

		content << "@end\n\n\n"

		return content
	end

	def is_number? string
  		true if Float(string) rescue false
	end

	#属性
	def createProperties(keys)
		
		for i in 0...keys.length
			key = keys[i]
			value = self.propertyDemoValues[i]

			if value.is_a?(Array)#数组类型
				keyClassName = "NSString"

				relateObj = value[0]
				if !relateObj.is_a?(String)
					#定义子类
					puts "Enter #{self.className}类中 #{key}的类名 ： "#输入了类名
					keyClassName = gets
					keyClassName = keyClassName.delete("\n")
					relateObj = value[0]
					relateKeys = relateObj.keys
					relateValues = relateObj.values
					relateModel = OCClass.new(keyClassName, relateKeys, relateValues)
					self.relateClasses << relateModel
				end

				#定义属性
				property = Property.new
				property.name = key
				property.containerPropertyClassName = keyClassName
				property.type =  "NSArray"
				property.relation_type = "strong"
				property.auto_type = "nonatomic"
				self.propertyies << property
			elsif value.is_a?(Hash)#字典类型
				#定义子类
				puts "Enter #{self.className}类中 #{key}的类名 ： "#输入了类名
				keyClassName = gets
				keyClassName = keyClassName.delete("\n")
				relateKeys = value.keys
				relateValues = value.values	
				relateModel = OCClass.new(keyClassName, relateKeys, relateValues)
				self.relateClasses << relateModel

				#定义属性
				property = Property.new
				property.name = key
				property.type =  keyClassName
				property.relation_type = "strong"
				property.auto_type = "nonatomic"
				self.propertyies << property

			else#简单类型
				# value.extend StringNumber
				property = Property.new
				property.name = key
				property.type =  is_number?(value) ? "NSNumber" : "NSString"
				property.relation_type = "strong"
				property.auto_type = "nonatomic"
				self.propertyies << property
			end
			
		end
	end
end

class Generator

	attr_accessor :ocClass

	def initialize
		yield self if block_given?
	end

	def setClassInfo(className, keys, values)
		self.ocClass = OCClass.new(className, keys, values)
	end

	def createHeaderFileContent

		headerContent = self.ocClass.createHFileContent

		return headerContent
	end

	def createMFileContent

		content = self.ocClass.createMFileContent

		return content
	end
end