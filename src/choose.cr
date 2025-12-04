require "option_parser"
require "./choose/license"

module Choose
  VERSION = "0.1.0"

  class Cli
    @@year : String?
    @@fullname : String?

    def self.banner
      str = <<-EOF
      choose - A wise license generator
    
      Usage:
        choose <command> license [output] [--options]

      Examples:
        choose info mpl-2
        choose need mit
        choose mpl-2 MPL-2.0.txt
        choose mit -u "John Doe" -y 2025

      Commands:
        list [license]                     List licenses
        info license                       Show info like choosealicense.com
        need license                       Show the copyright placeholder

      Options:
      EOF

      str
    end

    def self.run(argv)
      OptionParser.parse(argv) do |parser|
        parser.banner = Choose::Cli.banner

        parser.on "-y YEAR", "--year=YEAR", "Year of publishing" do |year|
          @@year = year
        end

        parser.on "-u NAME", "--fullname=NAME", "Fullname of copyright holder" do |fullname|
          @@fullname = fullname
        end

        parser.on "-v", "--version", "Show version" do
          puts Choose::VERSION
          exit
        end

        parser.on "-h", "--help", "Show help" do
          puts parser
          exit
        end

        parser.on "--bug", "Report bug" do
          puts "https://github.com/initdc/choose/issues"
          exit
        end

        parser.on "--made-by", "initdc" do
          puts "initdc"
          exit
        end

        parser.unknown_args do |args, options|
          case args.size
          when 0
            puts parser
            exit
          when 1
            command = args[0]
            case command
            when "list"
              puts Choose::License.glob("").map(&.split("/")[-1].sub(".txt", "")).join("\n")
            when "help"
              puts parser
              exit
            else
              license = args[0]

              year = @@year || Time.utc.year.to_s
              fullname = @@fullname || Choose::Cli.git_user_name

              path, raw = Choose::License.path_raw(license.to_s)
              license_key = path.split("/")[-1].sub(".txt", "")
              raw = Choose::Cli.replace(license_key, raw, year, fullname)

              File.write("LICENSE", raw)
            end
          when 2
            command = args[0]
            license = args[1]
            case command
            when "list"
              puts Choose::License.glob(license).map(&.split("/")[-1].sub(".txt", "")).join("\n")
            when "info"
              Choose::License.info(license)
            when "need"
              Choose::License.copyright_place(license)
            else
              license = args[0]
              output = args[1]

              year = @@year || Time.utc.year.to_s
              fullname = @@fullname || Choose::Cli.git_user_name

              path, raw = Choose::License.path_raw(license.to_s)
              license_key = path.split("/")[-1].sub(".txt", "")
              raw = Choose::Cli.replace(license_key, raw, year, fullname)

              File.write(output.to_s, raw)
            end
          else
            puts "Too many arguments"
          end
        end
      end
    end

    def self.replace(license, raw, year, fullname)
      if !Choose::License.replace_table.has_key?(license)
        return raw
      else
        placeholder = Choose::License.replace_table[license]
        if placeholder.is_a? Array
          return raw
        end

        copyright = placeholder.sub("[year]", year).sub("[fullname]", fullname)
        return raw.sub(placeholder, copyright)
      end
    end

    def self.git_user_name
      `git config user.name`.strip
    end
  end
end

Choose::Cli.run ARGV
