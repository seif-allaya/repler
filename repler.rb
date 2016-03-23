require 'colorize'
require 'optionparser'
def is_valid_user_input(input)
  char = input.to_s.upcase
  if char =="Y" || char =="N"
     return true
   else
    return false
  end
end

# return [string output, string error_message, integer exitcode, boolean exception ]
def execute(cmd)
  error_message=""
  exception = false
  # execute
  begin
      #output = ` #{cmd} `
      output = %x( #{cmd})
      #output = system(call "#{cmd}")
      retcode = $?.exitstatus
  rescue Exception => e
      error_message= e.message.red
      exception = true
  end
    #retcode = $?.exitstatus
    return  { "output" => output, "error" => error_message,
            "retcode" => retcode, "exception" => exception }
end

# Read
def read(file_path)
  instructions = File.read("instruction.lst").split("\n")
  puts instructions.length.to_s.blue << " Instruction to be executed"
  p instructions
  return instructions
end

def looper(cmds)
  index = 0
  cmds.each { |cmd|
    index = index + 1
    puts "[#{index}] repler> " << cmd.green
    retobject = execute(cmd)
    if retobject["exception"] || retobject["retcode"]!=0
    if retobject["output"].nil? then  retobject["output"] = "No output" end
    if retobject["retcode"].nil? then retobject["retcode"]= "Exit status undefined" end
      puts "[#{index}] repler(" << retobject["retcode"].to_s.cyan << ")> " << retobject["output"].to_s.blue << retobject["error"].to_s.gsub("\n","").red
      valid = false
      continue = ""
      until valid do
        puts "Would you like to continue ? [Y/N] "
        continue = gets.chomp
        valid = is_valid_user_input(continue)
      end
      if continue == "n" || continue == "N"
        abort
      end
    else
      #if retobject["output"].to_s == "" then retobject["output"] = "nothing to show" end
      puts "[#{index}] repler(" << retobject["retcode"].to_s.yellow << ")> " << retobject["output"].gsub("\n","").to_s.green
    end
  }
end

def main
  options = {}
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: ruby repler.rb [options]"
     opts.on('-i', '--input filename', 'Input instruction list') { |file| options[:file_path] = file }
   end
   begin
     optparse.parse!
     if options[:file_path].nil?
       raise OptionParser::MissingArgument
     end
   rescue OptionParser::ParseError => e
     puts "No file supplied, Noting to do!!".colorize(:red)
     puts optparse
     exit
   end
  looper(read(options[:file_path]))
end

main
