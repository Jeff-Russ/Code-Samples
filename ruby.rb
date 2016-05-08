
      ######--------------------------------------------######
      ######  By Jeff Russ https://github.com/Jeff-Russ ######
      ######--------------------------------------------######

module Utils
#  ________________________________________________________________
# /                 File i/o methods                               \

  # inserts in file_path_str, the contents of s_or_a_ins at line linenum 
  # file_path_str when a string will not add a newline so you can use it
  # to enter many lines with \n as newlines. Alternatively, you can use
  # an array of strings where each will be a new line.
  # linenum starts at 1 NOT 0 and can be negative (-1 is last line)
  def file_insert file_path_str, s_or_a_ins='', linenum=-1
    FileUtils.touch(file_path_str) unless File.exist? file_path_str
    arr = File.read(file_path_str).lines(separator="\n")
    linenum-=1 if linenum > 0
    s_or_a_ins.each { |e| e << "\n" } if s_or_a_ins.class == Array
    arr.insert linenum, s_or_a_ins
    string = arr.join
    File.open(file_path_str, "w+") { |f| f.write(string) }
  end

  # Reads file at path file_path_str and returns array of strings.
  # Each line will be a new element by default since file_to_a
  # looks for "\n" when breaking up file into the array but you can 
  # override this with any quoted character in the optional 2nd arg
  def file_to_a file_path_str, delimiter="\n"
    File.read(file_path_str).lines(separator=delimiter)
  end

  # overwrites file at path file_path_str with new contents provided by 
  # the string given as second argument.
  def s_to_file file_path_str, new_content_str='' 
    File.open(file_path_str, "w+") { |f| f.write(new_content_str) }
  end

#  ___________________________________________________________________
# /                 Other file related methods                        \

  # ls_grep? helps you see if a directory (1st argument string)
  # contains a dif/file with a name containing a string (2nd argument).
  # The first arg is assumed to be a full path unless you provide 3rd arg.
  # The 3rd arg can be :ror for the root of the current Rails app, 
  # :home for the user's home folder or a custom path string.
  def ls_grep? dir_str, grep_str, dir_parent_sym_or_s="/"
    dir_str.gsub /^\//, '' # remove starting '/' if found
    case parent_path 
    when :ror   then parent = Rails.root
    when :home  then parent = Dir.home
    when String then parent = dir_parent_sym_or_s
    end
    ls_cmd = "ls #{Rails.root}/#{dir_str} | grep '#{grep_str}'"
    (%x[ #{ls_cmd} ]) != ''
  end

  # Location the definition of just about anything.
  def locate_def str
    has_dot = has_dot? str
    str_upr = starts_upper? str
    if has_dot && str_upr
      splits = str.partition(".")
      clas = splits.first
      meth = splits.last
      eval "clas.method(meth).source_location"
    elsif !has_dot && !str_upr
      Object.method(str).source_location
    elsif 
      code = "#{str}.instance_methods(false).map {|m| #{str}"
      code << ".instance_method(m).source_location.first}.uniq"
      eval code
    end
  end

  def ror_path str # appends string arg with Rails.root
    "#{Rails.root}#{str}" 
  end 

  def ror_file_exists? str
    File.exist? "#{Rails.root}#{str}"
  end

#  __________________________________________________________________
# /         Rails bash commands made available in Ruby               \

  def g_model str # runs generate on arg (model name) just like in shell
    cmd = "rails generate model #{str}"
    puts %x[ #{cmd} ]
  end

  def d_model str # runs destroy on arg (model name) just like in shell
    cmd = "rails destroy model #{str}"
    puts %x[ #{cmd} ]
  end

  def g_cont str # runs generate on arg (controller name) just like in shell
    cmd = "rails generate controller #{str}"
    puts %x[ #{cmd} ]
  end

  def d_cont str # runs destroy on arg (controller name) just like in shell
    cmd = "rails destroy controller #{str}"
    puts %x[ #{cmd} ]
  end

#  __________________________________________________________________
# /              Rails ActiveRecord shortcuts                        \

  # finds migration file containing string provided by arg, ret's id
  def get_migration_id partial_filename
    ls_migr_file = "ls #{Rails.root}/db/migrate | grep '#{partial_filename}'"
    (%x[ #{ls_migr_file} ]).strip.gsub!(/\D/, '')
  end

  # Runs migration :up or :down set by arg 2, defaulted to :up
  # on migration file containing string provided by arg 1
  def run_migration_file partial_filename, direction=:up
    id = get_migration_id partial_filename
    "rake db:migrate:#{direction.to_s} VERSION=#{id}"
  end

  # get migration status as string
  def migration_status 
    stat = "rake db:migrate:status"
    %x[ #{stat} ] 
  end

  # get array of table names in less annoying syntax:
  def tables; ActiveRecord::Base.connection.tables; end 

  def table_exists? str
    ActiveRecord::Base.connection.tables.include? str
  end 

#  _____________________________________________________________
# /         String Manipulation and Evaluation                  \

  # These are all self-explanatory. all return booleans
  def is_upper?  str; str == str.upcase; end
  def is_lower?  str; str == str.downcase; end
  def has_regex? str, regex; !!(str =~ regex); end
  def has_dot?   str, regex; !!(str =~ /\./); end
  def has_upper? str; !!(str =~ /[A-Z]/); end
  def has_lower? str; !!(str =~ /[A-Z]/); end
  def starts_upper? str; !!(str.first =~ /[A-Z]/); end
  def starts_lower? str; !!(str.first =~ /[A-Z]/); end

  def prepend_each array, left_side
    array.map { |elem| elem = "#{left_side}#{elem}" }
  end
 
  def append_each array, right_side
    array.map { |elem| elem = "#{left_side}#{elem}#{right_side}" }
  end

  def wrap_each array, left_side, right_side
    array.map { |elem| elem = "#{left_side}#{elem}#{right_side}" }
  end
end