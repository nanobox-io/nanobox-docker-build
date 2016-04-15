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

  def deep_stringify_keys
    deep_transform_keys{ |key| key.to_s }
  end

  def deep_symbolize_keys
    deep_transform_keys{ |key| key.to_sym }
  end

  def deep_transform_keys(&block)
    _deep_transform_keys_in_object(self, &block)
  end

  def _deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = _deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map {|e| _deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end

  def prune_empty
    delete_if {|key, value| value.prune_empty if value.is_a? Hash; value.nil? or value.empty?}
  end
end

module Nanobox
  module Boxfile

    BOXFILE_DATA_DEFAULTS = {
      config:         {type: :hash, default: {}},
      image:          {type: :string, default: nil}
    }

    BOXFILE_BUILD_DEFAULTS = {
      config:         {type: :hash, default: {}},
      engine:         {type: :string, default: nil},
      image:          {type: :string, default: "nanobox/build"},
      lib_dirs:       {type: :array, of: :folders, default: []},

      before_setup:   {type: :array, of: :string, default: []},
      after_setup:    {type: :array, of: :string, default: []},
      before_prepare: {type: :array, of: :string, default: []},
      after_prepare:  {type: :array, of: :string, default: []},
      before_build:   {type: :array, of: :string, default: []},
      after_build:    {type: :array, of: :string, default: []}
    }

    BOXFILE_DEPLOY_DEFAULTS = {
      transform:      {type: :array, of: :string, default: []},
      before_deploy_all: {type: :hash, default: {}},
      after_deploy_all: {type: :hash, default: {}},
      before_deploy:  {type: :hash, default: {}},
      after_deploy:   {type: :hash, default: {}}
    }

    BOXFILE_DEV_DEFAULTS = {
      # TODO: something should be in here
    }

    BOXFILE_WEB_DEFAULTS = {
      image:          {type: :string, default: "nanobox/code"},
      start:          {type: :array, of: :string, default: []},
      routes:         {type: :array, of: :string, default: []},
      ports:          {type: :array, of: :string, default: []},

      before_deploy:  {type: :array, of: :string, default: []},
      after_deploy:   {type: :array, of: :string, default: []}
    }

    BOXFILE_WORKER_DEFAULTS = {
      image:          {type: :string, default: "nanobox/code"},
      start:          {type: :array, of: :string, default: []},

      before_deploy:  {type: :array, of: :string, default: []},
      after_deploy:   {type: :array, of: :string, default: []}
    }

    def boxfile_deploy_hooks_defaults(boxfile)
      $boxfile_deploy_hooks_defaults ||= begin
        template = {}
        boxfile.keys.each do |key|
          case key
          when /^web\./
            template[key] = {type: :array, of: :string, default: []}
          when /^worker\./
            template[key] = {type: :array, of: :string, default: []}
          end

        end
        template
      end
    end

    def boxfile
      registry('boxfile') || {}
    end

    def converged_app_boxfile
      $converged_app_boxfile ||= converge_boxfile(unconverged_app_boxfile)
    end

    def unconverged_app_boxfile
      $unconverged_app_boxfile ||= begin
        boxfile = {}
        if ::File.exist?("#{CODE_DIR}/boxfile.yml")
          boxfile = YAML::load(File.open("#{CODE_DIR}/boxfile.yml")).deep_symbolize_keys
        end
        boxfile
      end
    end

    def converged_engine_boxfile
      $converged_engine_boxfile ||= converge_boxfile(unconverged_engine_boxfile)
    end

    def unconverged_engine_boxfile
      $unconverged_engine_boxfile ||= begin
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
        YAML::load(output).deep_symbolize_keys
      end
    end

    def merged_boxfile
      $merged_boxfile ||= converge_boxfile(merge_boxfile(unconverged_engine_boxfile, unconverged_app_boxfile))
    end

    def converge_boxfile(original)
      boxfile = {}
      original.keys.each do |key|
        case key
        when /^data\./
          boxfile[key] = converge( BOXFILE_DATA_DEFAULTS, original[key] )
        when /^code\.build$/
          boxfile[key] = converge( BOXFILE_BUILD_DEFAULTS, original[key] )
        when /^code\.deploy$/
          boxfile[key] = converge( BOXFILE_DEPLOY_DEFAULTS, original[key] )
          boxfile[key][:before_deploy]     = converge(boxfile_deploy_hooks_defaults(original), boxfile[key][:before_deploy])
          boxfile[key][:before_deploy_all] = converge(boxfile_deploy_hooks_defaults(original), boxfile[key][:before_deploy_all])
          boxfile[key][:after_deploy]      = converge(boxfile_deploy_hooks_defaults(original), boxfile[key][:after_deploy])
          boxfile[key][:after_deploy_all]  = converge(boxfile_deploy_hooks_defaults(original), boxfile[key][:after_deploy_all])
        when /^dev$/
          boxfile[key] = converge( BOXFILE_DEV_DEFAULTS, original[key] )
        when /^web\./
          boxfile[key] = converge( BOXFILE_WEB_DEFAULTS, original[key] )
        when /^worker\./
          boxfile[key] = converge( BOXFILE_WORKER_DEFAULTS, original[key] )
        end
      end
      boxfile
    end

    def merge_boxfile(base, extra)
      base.deep_merge(extra)
    end

  end
end