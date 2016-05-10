require 'yaml'

module Nanobox
  module Boxfile

    # Base templates for the different nodes in the boxfile.

    BOXFILE_DATA_DEFAULTS = {
      type: :hash,
      default: {},
      template:  {
        config:         {type: :hash, default: {}},
        image:          {type: :string, default: nil}
      }
    }

    BOXFILE_BUILD_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        config:         {type: :hash, default: {}},
        engine:         {type: :string, default: nil},
        image:          {type: :string, default: nil},
        lib_dirs:       {type: :array, of: :folders, default: []},

        before_setup:   {type: :array, of: :string, default: []},
        after_setup:    {type: :array, of: :string, default: []},
        before_prepare: {type: :array, of: :string, default: []},
        after_prepare:  {type: :array, of: :string, default: []},
        before_compile:   {type: :array, of: :string, default: []},
        after_compile:    {type: :array, of: :string, default: []}
      }
    }

    BOXFILE_DEPLOY_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        transform:      {type: :array, of: :string, default: []}
      }
    }

    BOXFILE_DEV_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        cwd:             {type: :folder, default: nil}
        # TODO: something should be in here
      }
    }

    BOXFILE_WEB_STRING_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :string, default: nil},
        routes:         {type: :array, of: :string, default: []},
        ports:          {type: :array, of: :string, default: []}
      }
    }

    BOXFILE_WORKER_STRING_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :string, default: nil}
      }
    }

    BOXFILE_WEB_HASH_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :hash, default: {}},
        routes:         {type: :array, of: :string, default: []},
        ports:          {type: :array, of: :string, default: []}
      }
    }

    BOXFILE_WORKER_HASH_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :hash, default: {}}
      }
    }
    # Simple getter to retrieve the boxfile from the registry
    # the boxfile is set in the registry as the hooks progress
    def boxfile
      registry('boxfile') || {}
    end

    # This creates a validation template for a boxfile based
    # off of the existing nodes and the default nodes
    def template_boxfile(boxfile)
      template = {}
      # Add default nodes for the code.build, code.deploy,
      # and dev nodes
      template[:'code.build'] = BOXFILE_BUILD_DEFAULTS
      template[:'code.deploy'] = BOXFILE_DEPLOY_DEFAULTS
      template[:'code.deploy'][:template][:before_deploy] = boxfile_deploy_hooks_defaults(boxfile)
      template[:'code.deploy'][:template][:before_deploy_all] = boxfile_deploy_hooks_defaults(boxfile)
      template[:'code.deploy'][:template][:after_deploy] = boxfile_deploy_hooks_defaults(boxfile)
      template[:'code.deploy'][:template][:after_deploy_all] = boxfile_deploy_hooks_defaults(boxfile)
      template[:'dev'] = BOXFILE_DEV_DEFAULTS
      # Step through the boxfile and add validation for
      # code and data nodes.
      boxfile.keys.each do |key|
        case key
        when /^data\./
          template[key] = BOXFILE_DATA_DEFAULTS
        when /^code\.build$/
        when /^code\.deploy$/
        when /^dev$/
        when /^web\./
          if boxfile[key][:start].nil?
            # add error?
          elsif boxfile[key][:start].is_a? Hash
            template[key] = BOXFILE_WEB_HASH_DEFAULTS
          elsif boxfile[key][:start].is_a? String
            template[key] = BOXFILE_WEB_STRING_DEFAULTS
          else
            # add error?
          end
        when /^worker\./
          if boxfile[key][:start].nil?
            # add error?
          elsif boxfile[key][:start].is_a? Hash
            template[key] = BOXFILE_WORKER_HASH_DEFAULTS
          elsif boxfile[key][:start].is_a? String
            template[key] = BOXFILE_WORKER_STRING_DEFAULTS
          else
            # add error?
          end
        else
          # add error?
        end
      end
      template
    end

    # Create validations for before/after deploy hooks since they're a hash
    def boxfile_deploy_hooks_defaults(boxfile)
      $boxfile_deploy_hooks_defaults ||= begin
        template = {type: :hash, default: {}, template: {}}
        # Add entries for each web and worker node.
        boxfile.keys.each do |key|
          case key
          when /^web\./
            template[:template][key] = {type: :array, of: :string, default: []}
          when /^worker\./
            template[:template][key] = {type: :array, of: :string, default: []}
          end

        end
        template
      end
    end

    # Helper to converge a boxfile
    def converge_boxfile(original)
      converge(template_boxfile(original), original)
    end

  end
end
