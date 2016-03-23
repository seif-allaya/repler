require 'colorize'

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
  cmds.each { |cmd|
  puts "|> " << cmd.green
  retobject = execute(cmd)
  if retobject["exception"] || retobject["retcode"]!=0
    if retobject["output"].nil? then  retobject["output"] = "No output" end
    if retobject["retcode"].nil? then retobject["retcode"]= "Exit status undefined" end
    puts "|= " << retobject["retcode"].to_s.cyan << " : " << retobject["output"].to_s.blue << retobject["error"].to_s.gsub("\n","").red
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
    puts "|= " << retobject["retcode"].to_s.yellow << " : " << retobject["output"].gsub("\n","").to_s.green
  end
}
end

def main
  file_path = "./instruction.lst"
  looper(read(file_path))
end

main
