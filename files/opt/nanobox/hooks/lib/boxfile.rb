require 'yaml'

class Hash
  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end

  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end
    self
  end
end

module Nanobox
  module Boxfile

    BOXFILE_DATA_DEFAULTS = {
      config:        {type: :hash, default: {}},
      image:         {type: :string, default: nil}
    }

    BOXFILE_ENV_DEFAULTS = {
      config:        {type: :hash, default: {}},
      engine:        {type: :string, default: nil},
      image:         {type: :string, default: nil},

      before_build:  {type: :array, of: :string, default: []},
      after_build:   {type: :array, of: :string, default: []}
    }

    BOXFILE_WEB_DEFAULTS = {
      image:         {type: :string, default: nil},
      start:         {type: :array, of: :string, default: []},
      routes:        {type: :array, of: :string, default: []},
      ports:         {type: :array, of: :string, default: []},

      before_deploy: {type: :array, of: :string, default: []},
      after_deploy:  {type: :array, of: :string, default: []}
    }

    BOXFILE_WORKER_DEFAULTS = {
      image:         {type: :string, default: nil},
      start:         {type: :array, of: :string, default: []},

      before_deploy: {type: :array, of: :string, default: []},
      after_deploy:  {type: :array, of: :string, default: []}
    }

    def converged_boxfile
      $converged_boxfile ||= begin
        boxfile = {}
        if ::File.exist?("#{CODE_DIR}/Boxfile")
          boxfile = converge_boxfile(YAML::load(File.open("#{CODE_DIR}/Boxfile")))
        end
        boxfile
      end
    end

    def converge_engine_boxfile
      $converge_engine_boxfile ||= begin
        output = ''
        execute "generating boxfile" do
          command %Q(#{ENGINE_DIR}/#{registry('engine')}/bin/boxfile 'payload')
          cwd "#{ENGINE_DIR}/#{registry('engine')}/bin"
          path GONANO_PATH
          user 'gonano'
          stream true
          on_stderr {|data| logger.print data}
          on_stdout {|data| output << data}
        end
        converge_boxfile(output)
      end
    end

    def merged_boxfile
      $merged_boxfile ||= merge_boxfile(converge_engine_boxfile, converged_boxfile)
    end

    def converge_boxfile(original)
        boxfile = {}
        original.keys.each do |key|
          case key
          when /^data/
            boxfile[key] = converge( BOXFILE_DATA_DEFAULTS, original[key] )
          when /^env/
            boxfile[key] = converge( BOXFILE_ENV_DEFAULTS, original[key] )
          when /^web/
            boxfile[key] = converge( BOXFILE_WEB_DEFAULTS, original[key] )
          when /^worker/
            boxfile[key] = converge( BOXFILE_WORKER_DEFAULTS, original[key] )
          end
        end 
        boxfile
      end
    end

    def merge_boxfile(base, extra)
      base.deep_merge(extra)
    end

  end
end