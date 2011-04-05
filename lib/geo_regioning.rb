# GeoRegioning
%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

#Make the models happy
class GeoRegioning
  @@config = {}

  def self.config=(config)
    @@config = config
  end

  def self.config
    @@config
  end
end
