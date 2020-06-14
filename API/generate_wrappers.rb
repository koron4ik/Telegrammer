#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'fileutils'

HTML_FILE = 'api.html'
API_DIR = '../Sources/Telegrammer/Bot/Telegram'
API_FILE = 'api.txt'

TYPE_HEADER = <<EOT
// Telegrammer - Telegram Bot Swift SDK.
// This file is autogenerated by API/generate_wrappers.rb script.

EOT

METHOD_HEADER = <<EOT
// Telegrammer - Telegram Bot Swift SDK.
// This file is autogenerated by API/generate_wrappers.rb script.

EOT


	ONE   = "    "
	TWO   = "        "
	THREE = "            "
	FOUR  = "                "

class String
	def camel_case_lower
		self.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
	end

	def camel_case
    	return self if self !~ /_/ && self =~ /[A-Z]+.*/
    	split('_').map{|e| e.capitalize}.join
  	end
  	def capitalize_first
  		result = self
   		result[0] = result[0].upcase
   	 	return result
  	end
end

# Some of the variables have more convenient manually created helper methods,
# rename the original strings to something else
def make_getter_name(type_name, var_name, var_type, var_desc)
	case [type_name, var_name]
	#when ['Chat', 'type']
	#    return 'type_string'
	when ['ChatMember', 'status']
			return 'status_string'
	else
			if var_name == 'type' && var_type == 'String' then
					return 'type_string'
			elsif var_name.include?('date') && var_desc.include?('Unix time') then
					return var_name + '_unix'
			end
			return var_name
	end
end

def make_swift_type_name(var_name, var_type)
	array_prefix = 'Array of '
	if var_type.start_with?(array_prefix) then
		var_type.slice! array_prefix
        
        if var_type == 'InputMediaPhoto and InputMediaVideo' then
            return "[InputMediaPhotoAndVideo]"
        end
		return "[#{var_type}]"
	end

	case var_type
	when 'Boolean', 'True'
		return 'Bool'
	when 'Integer'
		if var_name.include?('user_id') || var_name.include?('chat_id') then
			return 'Int64'
		else
			return 'Int'
		end
	when 'Float number'
		return 'Float'
	when 'Integer or String'
		 if var_name.include?('chat_id') then
		 	return 'ChatId'
		 end
		 return 'String'
	when 'InputFile or String'
		return 'FileInfo'
	when 'InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply'
		return 'ReplyMarkup'
	when 'MessageOrBoolean'
		return 'MessageOrBool'
	when 'Messages'
		return '[Message]'
    when 'String'
        if var_name.include?('parse_mode') then
            return 'ParseMode'
        end
        return 'String'
	end
	return var_type
end

def make_request_parameter(request_name, swift_type_name, var_name, var_type, var_optional, var_desc)
    parameters = ""
    var_desc.each_line { |line|
        parameters << "#{TWO}/// #{line.strip}\n"
    }
    parameters << "#{TWO}var #{var_name.camel_case_lower}: #{swift_type_name}#{var_optional ? '?' : ''}\n\n"
    return parameters
end

def make_request_value(request_name, swift_type_name, var_name, var_type, var_optional, var_desc)
	return "#{THREE}case #{var_name.camel_case_lower} = \"#{var_name}\"\n"
end

def make_init_params(request_name, swift_type_name, var_name, var_type, var_optional, var_desc)
	optional = var_optional ? "? = nil" : ""
	return "#{var_name.camel_case_lower}: #{swift_type_name}#{optional}, "
end

def make_init_body(request_name, swift_type_name, var_name, var_type, var_optional, var_desc)
	var_name_cameled = var_name.camel_case_lower
	return "#{THREE}self.#{var_name_cameled} = #{var_name_cameled}\n"
end

def deduce_result_type(description)
	
	type_name = description[/invite link as (.+) on success/, 1]
	return type_name unless type_name.nil?
	
	type_name = description[/(\w+) with the final results is returned/, 1]
	return type_name unless type_name.nil?
	
	type_name = description[/An (.+) objects is returned/, 1]
	return type_name unless type_name.nil?

	type_name = description[/returns an (.+) objects/, 1]
	return type_name unless type_name.nil?
    
    type_name = description[/returns a (\w+) object/, 1]
    return type_name unless type_name.nil?

	type_name = description[/in form of a (.+) object/, 1]
	return type_name unless type_name.nil?

	type_name = description[/, a (.+) object is returned/, 1]
	return type_name unless type_name.nil?

	type_name = description[/(\w+) is returned, otherwise True is returned/, 1]
	return "#{type_name}OrBoolean" unless type_name.nil?

	type_name = description[/(\w+) is returned/, 1]
	return type_name unless type_name.nil?

	type_name = description[/Returns a (.+) object/, 1]
	return type_name unless type_name.nil?

	type_name = description[/Returns the uploaded (.+) on success./, 1]
	return type_name unless type_name.nil?

	type_name = description[/Returns (.+) on/, 1]
	return type_name unless type_name.nil?
	
	type_name = description[/invite link as (.+) on success/, 1]
	return type_name unless type_name.nil?

	return 'Boolean'
end

def fetch_description(current_node)
	description = ''
	while !current_node.nil? && current_node.name != 'table' &&
			current_node.name != 'h4' do
		text = current_node.text.strip

		if description.length != 0 then
			description += "\n"
		end
		description += text
		current_node = current_node.next_element
	end
	return description, current_node
end

def convert_type(var_name, var_desc, var_type, type_name, var_optional)
    if var_name == "type" then
        if var_desc.include?("Type of chat") then
            return "ChatType"
        end
        if var_desc.include?("Type of the entity") then
            return "MessageEntityType"
        end
    end
    
	case [var_type, var_optional]
	when ['String', true]
		return "String?"
	when ['String', false]
        return "String"
    when ['InputFile or String', true]
        return "FileInfo?"
    when ['InputFile or String', false]
        return "FileInfo"
	when ['Integer', true]
		is64bit = var_name.include?("user_id") || var_name.include?("chat_id") || var_desc.include?("64 bit integer") ||
							(type_name == 'User' && var_name == 'id')
		suffix = is64bit ? '64' : ''
		return "Int#{suffix}?"
	when ['Integer', false]
		is64bit = var_name.include?("user_id") ||
                  var_name.include?("chat_id") ||
                  var_desc.include?("64 bit integer") ||
                  (type_name == 'User' && var_name == 'id')
		suffix = is64bit ? '64' : ''
		return "Int#{suffix}"
	when ['Float number', true], ['Float', true]
		return "Float?"
	when ['Float number', false], ['Float', false]
		return "Float"
	when ['Boolean', true], ['True', true]
		return "Bool?"
	when ['Boolean', false], ['True', false]
		if var_type == 'True' then
			return "Bool = true"
		else 
			return "Bool"
		end
	else
		two_d_array_prefix = 'Array of Array of '
		array_prefix = 'Array of '
		if var_type.start_with?(two_d_array_prefix) then
			var_type.slice! two_d_array_prefix
			# Present optional arrays as empty arrays
			if var_optional then
				return "[[#{var_type}]]?"
			else
				return "[[#{var_type}]]"
			end
		elsif var_type.start_with?(array_prefix) then
			var_type.slice! array_prefix
            if var_type == 'Integer' then
                var_type = 'Int'
            end
			# Present optional arrays as empty arrays
			if var_optional then
				return "[#{var_type}]?"
			else
				return "[#{var_type}]"
			end
		else
			if var_optional then
				return "#{var_type}?"
			else
				return "#{var_type}"
			end
		end
	end
end

def generate_model_file(f, node)
	models_dir = 'Models'
	FileUtils.mkpath "#{API_DIR}/#{models_dir}"

	current_node = node

	type_name = current_node.text
	File.open("#{API_DIR}/#{models_dir}/#{type_name}.swift", "wb") { | out |
		out.write TYPE_HEADER
		
		current_node = current_node.next_element
		description, current_node = fetch_description(current_node)

		f.write "DESCRIPTION:\n#{description}\n"
        
		keys_block = ""
		vars_block = ""
		init_params_block = ""
		init_block = ""

		current_node.search('tr').each { |node|
			td = node.search('td')
			next unless !(td[0].nil? || td[0] == 0) && (td[0].text != 'Field' && td[0].text != 'Parameters')

			var_name = td[0].text
			var_type = td[1].text
			var_desc = td[2].text
			var_optional = var_desc.start_with? "Optional"
			f.write "PARAM: #{var_name} [#{var_type}#{var_optional ? '?' : ''}]: #{var_desc}\n"
            
			correct_var_type = convert_type(var_name, var_desc, var_type, type_name, var_optional)
			correct_var_type_init = correct_var_type[-1] == "?" ? correct_var_type + " = nil" : correct_var_type
			var_name_camel = var_name.camel_case_lower

			keys_block        << "#{TWO}case #{var_name_camel} = \"#{var_name}\"\n"
            
            var_desc.each_line { |line|
                vars_block        << "#{ONE}/// #{line.strip}\n"
            }
            
			vars_block        << "#{ONE}public var #{var_name_camel}: #{correct_var_type}\n\n"
			init_params_block << "#{var_name_camel}: #{correct_var_type_init}, "
			init_block        << "#{TWO}self.#{var_name_camel} = #{var_name_camel}\n"
		}
        if type_name == "MaskPosition" then
            out.write "import TelegrammerMultipart\n\n"
        end

        out.write "/**\n"
        description.each_line { |line|
            out.write " #{line.strip}\n"
        }
        out.write "\n"
        
        out.write " SeeAlso Telegram Bot API Reference:\n"
        out.write " [#{type_name}](https://core.telegram.org/bots/api\##{type_name.downcase})\n"
        out.write " */\n"

        var_protocol = "Codable"

        if type_name == "MaskPosition" then
            var_protocol += ", MultipartPartConvertible"
        end

        if type_name.start_with?('InputMedia') then
            var_protocol = "Encodable"
        end
        out.write  "public final class #{type_name}: #{var_protocol} {\n\n"
        
        if keys_block != "" then
            out.write "#{ONE}/// Custom keys for coding/decoding `#{type_name}` struct\n"\
            "#{ONE}enum CodingKeys: String, CodingKey {\n"\
            "#{keys_block}"\
            "#{ONE}}\n"\
            "\n"\
            "#{vars_block}"\
            "#{ONE}public init (#{init_params_block.chomp(', ')}) {\n"\
            "#{init_block}"\
            "#{ONE}}\n"
        end
        out.write  "}\n"
	}
end

def generate_method(f, node)
	models_dir = 'Methods'
	FileUtils.mkpath "#{API_DIR}/#{models_dir}"

	current_node = node

	method_name = current_node.text
	File.open("#{API_DIR}/#{models_dir}/Bot+#{method_name}.swift", "wb") { | out |
		out.write METHOD_HEADER
		out.write "public extension Bot {\n"
		out.write "\n"

		current_node = current_node.next_element
		description, current_node = fetch_description(current_node)

		result_type = deduce_result_type(description)
		result_type = make_swift_type_name('', result_type)

		codable_params_struct = ""
		codable_params_enum = ""
		
		f.write "DESCRIPTION:\n#{description}\n"

		anchor = method_name.downcase

		vars_desc = ""
		all_params = ""
		all_enums = ""
		init_params_body = ""
		init_params = ""
		
		has_obligatory_params = false
		has_upload_type = false
		
		current_node.search('tr').each { |node|
			td = node.search('td')
			next unless !(td[0].nil? || td[0] == 0) && (td[0].text != 'Parameters')

			var_name = td[0].text
			var_type = td[1].text
			var_optional = td[2].text.strip != 'Yes'
			var_desc = td[3].text
			f.write "PARAM: #{var_name} [#{var_type}#{var_optional ? '?' : ''}]: #{var_desc}\n"
			
			if !has_obligatory_params then
				if !var_optional then
					has_obligatory_params = true
				end
			end
			
			swift_type_name = make_swift_type_name(var_name, var_type)
			
			if swift_type_name == "FileInfo" || swift_type_name == "InputFile" then
				has_upload_type = true
			end
			
			all_params << make_request_parameter(method_name, swift_type_name, var_name, var_type, var_optional, var_desc)
			all_enums << make_request_value(method_name, swift_type_name, var_name, var_type, var_optional, var_desc)
			init_params << make_init_params(method_name, swift_type_name, var_name, var_type, var_optional, var_desc)
			init_params_body << make_init_body(method_name, swift_type_name, var_name, var_type, var_optional, var_desc)

			if vars_desc.empty? then
				vars_desc += "    /// - Parameters:\n"
			end
			vars_desc +=   "    ///     - #{var_name}: "
			first_line = true
			var_desc.each_line { |line|
				stripped = line.strip
				next unless !stripped.empty?
				if first_line then
					first_line = false
				else
					vars_desc += '    ///       '
				end
				vars_desc +=   "#{line.strip}\n"\
			}
		}

        method_name_capitalized = method_name.dup
        method_name_capitalized = "#{method_name_capitalized.capitalize_first}Params"

#		body_param = ", body: HTTPBody(), headers: HTTPHeaders()"
        body_param = ""

        #Generate description
        method_description = ""
        method_description << "#{ONE}/**\n"
        
        description.each_line { |line|
            method_description << "#{ONE} #{line.strip}\n"
        }
        
        method_description << "\n"
        method_description << "#{ONE} SeeAlso Telegram Bot API Reference:\n"
        method_description << "#{ONE} [#{method_name_capitalized}](https://core.telegram.org/bots/api\##{anchor})\n"
        method_description << "#{ONE} \n"
        method_description << "#{ONE} - Parameters:\n"
        method_description << "#{TWO} - params: Parameters container, see `#{method_name_capitalized}` struct\n"
        method_description << "#{ONE} - Throws: Throws on errors\n"
        method_description << "#{ONE} - Returns: Future of `#{result_type}` type\n"
        method_description << "#{ONE} */\n"

	if all_params.empty? then
		params_block = "(params: #{method_name_capitalized}? = nil)"
        out.write method_description
        out.write "#{ONE}@discardableResult\n"
		out.write "#{ONE}func #{method_name}() throws -> Future<#{result_type}> {\n"
	else
	
		encodable_type = "JSONEncodable"
	
		if has_upload_type then
			encodable_type = "MultipartEncodable"
		end
        out.write "#{ONE}/// Parameters container struct for `#{method_name}` method\n"
		out.write "#{ONE}struct #{method_name_capitalized}: #{encodable_type} {\n\n"
		out.write "#{all_params}"
        out.write "#{TWO}/// Custom keys for coding/decoding `#{method_name_capitalized}` struct\n"
		out.write "#{TWO}enum CodingKeys: String, CodingKey {\n"
		out.write "#{all_enums}"
		out.write "#{TWO}}\n"
		out.write "\n"
		out.write "#{TWO}public init(#{init_params.chomp(', ')}) {\n"
		out.write "#{init_params_body}"
		out.write "#{TWO}}\n"
		out.write "#{ONE}}\n"
		out.write "\n"
		if has_obligatory_params then
			params_block = "(params: #{method_name_capitalized})"
		else
			params_block = "(params: #{method_name_capitalized}? = nil)"
		end
        
        out.write method_description
        out.write "#{ONE}@discardableResult\n"
		out.write "#{ONE}func #{method_name}#{params_block} throws -> Future<#{result_type}> {\n"

		out.write "#{TWO}let body = try httpBody(for: params)\n"
		out.write "#{TWO}let headers = httpHeaders(for: params)\n"
		body_param = ", body: body, headers: headers"
	end
	
	out.write "#{TWO}return try client\n"\
              "#{THREE}.request(endpoint: \"#{method_name}\"#{body_param})\n"\
              "#{THREE}.flatMapThrowing { (container) -> #{result_type} in\n"\
              "#{FOUR}return try self.processContainer(container)\n"\
              "#{TWO}}\n"\
			  "#{ONE}}\n"\
			  "}\n"
	}

end

def main
	STDOUT.sync = true

	File.open(API_FILE, 'wb') { |f|
		html = File.open(HTML_FILE, "rb").read
		doc = Nokogiri::HTML(html)

		doc.css("br").each { |node| node.replace("\n") }
		
		doc.search("h4").each { |node|
			title = node.text.strip
			next unless title.split.count == 1

			# These types are complex and created manually:
			next unless !['InlineQueryResult', 'InputFile', 'InputMedia', 'InputMessageContent', 'PassportElementError'].include?(title)

			kind = (title.chars.first == title.chars.first.upcase) ? :type : :method

			f.write "NAME: #{title} [#{kind}]\n"

			if kind == :type then
                generate_model_file f, node
			else
		        generate_method f, node
			end

			f.write "\n"
		}
	}

	puts 'Finished'
end

if $0 == __FILE__
	if File.new(__FILE__).flock(File::LOCK_EX | File::LOCK_NB)
		main
	else
		raise 'Another instance of this program is running'
	end
end
