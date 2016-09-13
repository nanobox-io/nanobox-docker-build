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
        extra_packages: {type: :array, of: :strings, default: nil},
        dev_packages:   {type: :array, of: :strings, default: nil},

        before_setup:     {type: :array, of: :string, default: []},
        after_setup:      {type: :array, of: :string, default: []},
        before_prepare:   {type: :array, of: :string, default: []},
        after_prepare:    {type: :array, of: :string, default: []},
        before_compile:   {type: :array, of: :string, default: []},
        after_compile:    {type: :array, of: :string, default: []}
      }
    }

    BOXFILE_DEPLOY_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        deploy_hook_timeout:  {type: :integer, default: nil},
        transform:            {type: :array, of: :string, default: []}
      }
    }

    BOXFILE_DEV_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        cwd:      {type: :folder, default: nil},
        fs_watch: {type: :on_off, default: nil}
      }
    }

    BOXFILE_WEB_STRING_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :string, default: nil},
        routes:         {type: :array, of: :string, default: []},
        ports:          {type: :array, of: :string, default: []},
        writable_dirs:  {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:       {type: :hash, default: {}}
      }
    }

    BOXFILE_WORKER_STRING_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :string, default: nil},
        writable_dirs:  {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:       {type: :hash, default: {}}
      }
    }

    BOXFILE_WEB_HASH_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :hash, default: {}},
        routes:         {type: :array, of: :string, default: []},
        ports:          {type: :array, of: :string, default: []},
        writable_dirs:  {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:       {type: :hash, default: {}}
      }
    }

    BOXFILE_WORKER_HASH_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :hash, default: {}},
        writable_dirs:  {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:       {type: :hash, default: {}}
      }
    }

    BOXFILE_DATA_VALIDATOR = {
      image:  { types: [:string], required: true },
      config: { types: [:hash] }
    }

    BOXFILE_BUILD_VALIDATOR = {
      config:           { types: [:hash] },
      engine:           { types: [:string], required: true },
      image:            { types: [:string] },
      lib_dirs:         { types: [:array_of_strings] },
      extra_packages:   { types: [:array_of_strings] },
      dev_packages:     { types: [:array_of_strings] },
      before_setup:     { types: [:string, :array_of_strings] },
      after_setup:      { types: [:string, :array_of_strings] },
      before_prepare:   { types: [:string, :array_of_strings] },
      after_prepare:    { types: [:string, :array_of_strings] },
      before_compile:   { types: [:string, :array_of_strings] },
      after_compile:    { types: [:string, :array_of_strings] }
    }

    BOXFILE_DEPLOY_VALIDATOR = {
      deploy_hook_timeout:  { types: [:integer] },
      transform:            { types: [:string, :array_of_strings] },
      before_deploy:        { types: [:hash] },
      before_deploy_all:    { types: [:hash] },
      after_deploy:         { types: [:hash] },
      after_deploy_all:     { types: [:hash] }
    }

    BOXFILE_DEV_VALIDATOR = {
      cwd:      { types: [:string] },
      fs_watch: { types: [:boolean] }
    }

    BOXFILE_WEB_VALIDATOR = {
      image:          { types: [:string] },
      start:          { types: [:string, :array_of_strings], required: true },
      routes:         { types: [:array_of_strings] },
      ports:          { types: [:array_of_strings] },
      cron:           { types: [:array_of_hashes] },
      log_watch:      { types: [:hash] },
      network_dirs:   { types: [:hash] },
      writable_dirs:  { types: [:array_of_strings] }
    }

    BOXFILE_WORKER_VALIDATOR = {
      image:          { types: [:string] },
      start:          { types: [:string, :array_of_strings], required: true },
      cron:           { types: [:array_of_hashes] },
      log_watch:      { types: [:hash] },
      network_dirs:   { types: [:hash] },
      writable_dirs:  { types: [:array_of_strings] }
    }

    BOXFILE_CRON_VALIDATOR = {
      id:       { types: [:string] },
      schedule: { types: [:string] },
      command:  { types: [:string] }
    }

    # Simple getter to retrieve the boxfile from the registry
    # the boxfile is set in the registry as the hooks progress
    def boxfile
      registry('boxfile') || {}
    end

    # Validate the boxfile and return any validation errors
    def validate_boxfile(boxfile)
      errors = {}

      boxfile.each_pair do |key, value|
        case key
        when /^dev$/
          dev_errors = validate_section(value, BOXFILE_DEV_VALIDATOR)
          if dev_errors != {}
            errors[key] = dev_errors
          end
        when /^code\.build$/
          build_errors = validate_section(value, BOXFILE_BUILD_VALIDATOR)
          if build_errors != {}
            errors[key] = build_errors
          end
        when /^code\.deploy$/
          deploy_errors = validate_section(value, BOXFILE_DEPLOY_VALIDATOR)
          if deploy_errors != {}
            errors[key] = deploy_errors
          end
        when /^web\./
          web_errors = validate_section(value, BOXFILE_WEB_VALIDATOR)
          if not value[:cron].nil? and value[:cron].is_a? Array
            value[:cron].each do |cron|
              errors = validate_section(cron, BOXFILE_CRON_VALIDATOR)
              if errors != {}
                web_errors[:cron] = "Invalid cron format"
                break
              end
            end
          end
          if web_errors != {}
            errors[key] = web_errors
          end
        when /^worker\./
          worker_errors = validate_section(value, BOXFILE_WORKER_VALIDATOR)
          if not value[:cron].nil? and value[:cron].is_a? Array
            value[:cron].each do |cron|
              errors = validate_section(cron, BOXFILE_CRON_VALIDATOR)
              if errors != {}
                web_errors[:cron] = "Invalid cron format"
                break
              end
            end
          end
          if worker_errors != {}
            errors[key] = worker_errors
          end
        when /^data\./
          data_errors = validate_section(value, BOXFILE_DATA_VALIDATOR)
          if data_errors != {}
            errors[key] = data_errors
          end
        else
          errors[key] = 'Invalid node'
        end
      end

      # if we have errors at this point, let's go ahead and exit
      if errors != {}
        return errors
      end

      # now let's check for integrity (ensure net_dirs/hooks are correct etc)
      boxfile.each_pair do |key, value|

        # verify network_dirs point to actual data components
        if key =~ /^(web|worker)\./
          if not value[:network_dirs].nil? and value[:network_dirs].is_a? Hash
            value[:network_dirs].keys.each do |component|
              if not component =~ /^data\./ or boxfile[component].nil?
                if errors[key].nil?
                  errors[key] = {}
                end
                if errors[key][:network_dirs].nil?
                  errors[key][:network_dirs] = {}
                end
                errors[key][:network_dirs][component] \
                  = "#{component} is not a valid data node"
              end
            end
          end
        end

        # verify deploy hooks point to actual web or woker components
        if key =~ /^code.deploy$/
          value.each_pair do |k2, v2|
            if k2 =~ /(before|after)_deploy($|_all$)/
              v2.keys.each do |component|
                if not component =~ /^(web|worker)\./ or boxfile[component].nil?
                  if errors[key].nil?
                    errors[key] = {}
                  end
                  if errors[key][k2].nil?
                    errors[key][k2] = {}
                  end
                  errors[key][k2][component] \
                    = "#{component} is not a valid web or worker node"
                end
              end
            end
          end
        end
      end

      errors
    end

    # Validate a section with a validator. Returns any errors
    def validate_section(conf, validator)
      errors = {}

      # first let's iterate through the provided configuration
      conf.each_pair do |key, value|
        # let's make sure the conf is supported
        if validator[key].nil?
          errors[key] = 'Invalid node'
          next
        end

        # now let's make sure it's the right type
        case value
        when String
          if not validator[key][:types].include? :string
            errors[key] = supported_types_to_s(validator[key][:types])
          end
        when Integer
          if not validator[key][:types].include? :integer
            errors[key] = supported_types_to_s(validator[key][:types])
          end
        when TrueClass, FalseClass
          if not validator[key][:types].include? :boolean
            errors[key] = supported_types_to_s(validator[key][:types])
          end
        when Hash
          if not validator[key][:types].include? :hash
            errors[key] = supported_types_to_s(validator[key][:types])
          end
        when Array
          case value.first
          when String
            if not validator[key][:types].include? :array_of_strings
              errors[key] = supported_types_to_s(validator[key][:types])
            end
          when Integer
            if not validator[key][:types].include? :array_of_integers
              errors[key] = supported_types_to_s(validator[key][:types])
            end
          when Hash
            if not validator[key][:types].include? :array_of_hashes
              errors[key] = supported_types_to_s(validator[key][:types])
            end
          else
            errors[key] = supported_types_to_s(validator[key][:types])
          end
        else
          errors[key] = supported_types_to_s(validator[key][:types])
        end

      end

      # now let's iterate through the validator and check for required values
      validator.each_pair do |key, value|
        if value[:required] and value[:required] == true
          if not conf.include? key
            errors[key] = 'Cannot be empty'
          end
        end
      end

      errors
    end

    # Generates a clear message informing the supported types
    def supported_types_to_s(types)
      msgs = []

      if types.include? :string
        msgs << "a string"
      end

      if types.include? :integer
        msgs << "an integer"
      end
      
      if types.include? :boolean
        msgs << "true or false"
      end

      if types.include? :array_of_strings
        msgs << "an array of strings"
      end

      if types.include? :array_of_integers
        msgs << "an array of integers"
      end

      if types.include? :array_of_hashes
        msgs << "an array of hashes"
      end

      if types.include? :hash
        msgs << "a hash"
      end

      msg = "Must be "

      if msgs.length == 1
        msg << msgs.first
      elsif msgs.length == 2
        msg << "#{msgs[0]} or #{msgs[1]}"
      else
        last = msgs.pop
        msg << "#{msgs.join(", ")} or #{last}"
      end

      msg
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
