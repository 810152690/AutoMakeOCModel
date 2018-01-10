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

	def initialize
		yield self if block_given?
	end

	def property_declare_str
		"@property(#{auto_type}, #{relation_type}) #{type}* #{name};"
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

	def initialize (keys, values)
		yield self if block_given?
		#初始化变量
		self.propertyies = []
		self.propertyDemoValues = values
		self.relateClasses = []
		self.createProperties(keys)
	end

	def addProperty(p)
		self.propertyies << p
	end

	def setClassName(className)
		self.className = className
	end

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

	def createMFileContent
		className = self.className.delete("\n")

		content = ""
		for i in 0...self.relateClasses.length
			relateClass = self.relateClasses[i]
			content << relateClass.createMFileContent
		end

		content << "@implementation #{className} \n\n\n@end\n\n\n"

		return content
	end

	def is_number? string
  		true if Float(string) rescue false
	end

	def createProperties(keys)
		
		for i in 0...keys.length
			puts "property #{self.propertyDemoValues[i]}"
			key = keys[i]
			value = self.propertyDemoValues[i]
			#递归处理
			if key.include? "<"#关联类标识
				relateClassNameArr = key.split("<")
				key = relateClassNameArr[0]#解析出真正的key(去掉<后面的内容)

				relateClassNameAfter = relateClassNameArr[1]
				relateClassNameAfterArr = relateClassNameAfter.split(">")
				relateClassName = relateClassNameAfterArr[0]
				puts "relateClassName #{relateClassName}"

				type = "NSArray"
				if !relateClassName.empty? && !relateClassName.eql?("NSString")#既不是空的类型也不是NSString类型
					if !value.empty?
						relateObj = value[0]
						relateKeys = relateObj.keys
						relateValues = relateObj.values

						relateModel = OCClass.new(relateKeys, relateValues)
						relateModel.className = relateClassName;

						self.relateClasses << relateModel
					end	
				end

				property = Property.new
				property.name = key
				property.type =  type
				property.relation_type = "strong"
				property.auto_type = "nonatomic"

				self.propertyies << property

			else#简单类型
				# value.extend StringNumber
				puts is_number?(value)


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
	attr_accessor :className

	def initialize
		yield self if block_given?
	end

	def addClass(ocClass)
		self.ocClass = ocClass
		if self.className
			className = self.className.delete("\n")
			self.ocClass.className = className
		end
	end

	def setClassName(className)
		self.className = className
		if self.ocClass
			className = self.className.delete("\n")
			self.ocClass.className = className
		end
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