require "yaml"

class LicenseType
  include YAML::Serializable

  property title : String
  @[YAML::Field(key: "spdx-id")]
  property spdx_id : String
  property description : String
  property how : String
  property permissions : Array(String)
  property conditions : Array(String)
  property limitations : Array(String)

  property using : Hash(String, String)?
  property nickname : String?
  property note : String?
  property featured : String?
  property hidden : String?
  property redirect_from : String?
end

class Choose::License
  class NotFound < Exception; end

  class MoreThanOne < Exception; end

  LICENSE_DIR = Path["_license"]

  @@width = 80

  private def self.auto_wrap(str : String, width : Int32 = @@width)
    words = str.split(/\s+/) # one or more spaces
    lines = [] of String
    current_line = ""

    words.each do |word|
      if current_line.empty?
        current_line = word
      elsif current_line.size + word.size + 1 <= width
        current_line += " " + word
      else
        lines << current_line
        current_line = word
      end
    end

    # last line
    if !current_line.empty?
      lines << current_line
    end

    lines.join("\n")
  end

  def self.glob(pattern : String)
    pattern = pattern.downcase
    if File.exists?(LICENSE_DIR / "#{pattern}.txt")
      return [LICENSE_DIR / "#{pattern}.txt"]
    end

    if !pattern.ends_with?("*")
      pattern = pattern + "*"
    end
    Dir.glob(LICENSE_DIR / pattern).map { |x| Path[x] }.sort!
  end

  def self.parse(pattern : String)
    files = glob(pattern)
    if files.size > 0
      files.map { |f| LicenseType.from_yaml(File.read(f)) }
    else
      raise Choose::License::NotFound.new("License not found: #{pattern}")
    end
  end

  def self.info(pattern : String)
    parse(pattern).each_with_index do |license, i|
      num = i + 1
      puts "=" * (@@width - 10) + " No. " + sprintf("%02d", num) + " =="

      puts "title:      #{license.title}"
      puts "spdx-id:    #{license.spdx_id}"
      if license.nickname
        puts "nickname:   #{license.nickname}"
      end
      puts "=" * @@width

      puts "description:"
      puts auto_wrap license.description
      puts

      print "how: "
      puts auto_wrap license.how
      puts

      if license.note
        note = license.note || ""

        print "note: "
        puts auto_wrap note
        puts
      end

      if license.using
        using = license.using || {} of String => String

        puts "using:"
        using.each do |proj, url|
          fmt_proj = "  - #{proj}: "
          print fmt_proj
          if url.size + fmt_proj.size <= @@width
            puts url
          else
            puts
            puts " " * 6 + url
          end
        end
        puts
      end

      puts "permissions:"
      puts "  - " + license.permissions.join("\n  - ")
      puts

      puts "conditions:"
      puts "  - " + license.conditions.join("\n  - ")
      puts

      puts "limitations:"
      puts "  - " + license.limitations.join("\n  - ")
      puts
    end
    puts "-" * @@width
  end

  def self.path_raw(pattern : String)
    files = glob(pattern)
    case files.size
    when 1
      return files[0], File.read(files[0]).split(/\R---\R\R/)[1]
    when 0
      raise Choose::License::NotFound.new("License not found: #{pattern}")
    else
      puts "  - " + files.map(&.stem).join("\n  - ")
      raise Choose::License::MoreThanOne.new("More than one license found: #{pattern}")
    end
  end

  def self.copyright_place(pattern : String)
    pattern = pattern.downcase
    replace_table.each do |key, value|
      if key.to_s.includes?(pattern)
        puts "#{key}: #{value}"
      end
    end
  end

  def self.replace_table
    {
      "0bsd": "Copyright (c) [year] [fullname]",
      # "afl-3.0",
      # "agpl-3.0",
      # "apache-2.0",
      # "artistic-2.0",
      # "blueoak-1.0.0",
      "bsd-2-clause-patent": "Copyright (c) [year] [fullname]",
      "bsd-2-clause":        "Copyright (c) [year], [fullname]",
      "bsd-3-clause-clear":  "Copyright (c) [year] [fullname]",
      "bsd-3-clause":        "Copyright (c) [year], [fullname]",
      "bsd-4-clause":        "Copyright (c) [year], [fullname]",
      # "bsl-1.0",
      # "cc-by-4.0",
      # "cc-by-sa-4.0",
      # "cc0-1.0",
      # "cecill-2.1",
      # "cern-ohl-p-2.0",
      # "cern-ohl-s-2.0",
      # "cern-ohl-w-2.0",
      # "ecl-2.0",
      # "epl-1.0",
      # "epl-2.0",
      # "eupl-1.1",
      # "eupl-1.2",
      # "gfdl-1.3",
      # "gpl-2.0",
      # "gpl-3.0",
      "isc": "Copyright (c) [year] [fullname]",
      # "lgpl-2.1",
      # "lgpl-3.0",
      # "lppl-1.3c",
      "mit-0": "Copyright [year] [fullname]",
      "mit":   "Copyright (c) [year] [fullname]",
      # "mpl-2.0",
      # "ms-pl",
      # "ms-rl",
      "mulanpsl-2.0": [
        "Copyright (c) [Year] [name of copyright holder]",
        "[Software Name] is licensed under Mulan PSL v2.",
      ],
      "ncsa": [
        "[year]",
        "[fullname]",
        "[project]",
        "[projecturl]",
      ],
      # "odbl-1.0",
      "ofl-1.1": "Copyright (c) [year] [fullname] ([email])",
      # "osl-3.0",
      "postgresql": "Copyright (c) [year], [fullname]",
      # "unlicense",
      "upl-1.0": "Copyright (c) [year] [fullname]",
      "vim":     [
        "[project]",
      ],
      # "wtfpl",
      "zlib": "(C) [year] [fullname]",
    }
  end
end
