task default: []

task :dirs do
  sh "mkdir -p upload"
end

task :debug do
  sh "shards build"
end

task :release do
  sh "shards build --release"
end

task :upload => [:dirs, :release] do
    file = "choose_v0.1.0_#{platform}"
    sum = file + ".sha256sum"
  sh "cp bin/choose upload/#{file}"
  Dir.chdir("upload") do
    sh "sha256sum #{file} > #{sum}"
  end
end

def platform
  if defined?(Gem::Platform)
    Gem::Platform.local.os
  else
    case RUBY_PLATFORM
    when /darwin/
      'macos'
    when /linux/
      'linux'
    when /mswin|mingw|cygwin/
      'windows'
    else
      'unknown'
    end
  end
end
