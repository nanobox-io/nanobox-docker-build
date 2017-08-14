require 'yaml'

module Nanobox
  module Boxfile

    # Base templates for the different nodes in the boxfile.

    BOXFILE_CRON_DEFAULTS = {
      type: :array,
      of: :hash,
      default: [],
      template: {
        id:       { type: :string, default: nil },
        schedule: { type: :string, default: nil },
        command:  { type: :string, default: nil }
      }
    }

    BOXFILE_DATA_DEFAULTS = {
      type: :hash,
      default: {},
      template:  {
        config:          {type: :hash, default: {}},
        image:           {type: :string, default: nil},
        extra_packages:  {type: :array, of: :string, default: []},
        extra_path_dirs: {type: :array, of: :string, default: []},
        extra_steps:     {type: :array, of: :string, default: []},
        local_only:      {type: :on_off, default: nil},
        cron:            BOXFILE_CRON_DEFAULTS
      }
    }

    BOXFILE_RUN_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        "engine.config": {type: :hash, default: {}},
        engine:          {type: :string, default: nil},
        image:           {type: :string, default: nil},
        cache_dirs:      {type: :array, of: :folders, default: []},
        extra_packages:  {type: :array, of: :string, default: []},
        dev_packages:    {type: :array, of: :string, default: []},
        extra_path_dirs: {type: :array, of: :string, default: []},
        extra_steps:     {type: :array, of: :string, default: []},
        cwd:             {type: :folder, default: nil},
        fs_watch:        {type: :on_off, default: nil},
        build_triggers:  {type: :array, of: :string, default: []}
      }
    }

    BOXFILE_DEPLOY_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        extra_steps:          {type: :array, of: :string, default: []},
        deploy_hook_timeout:  {type: :integer, default: nil},
        transform:            {type: :array, of: :string, default: []}
      }
    }

    BOXFILE_WEB_STRING_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        cwd:            {type: :string, default: nil},
        start:          {type: :string, default: nil},
        stop:           {type: :string, default: nil},
        stop_timeout:   {type: :integer, default: nil},
        stop_force:     {type: :boolean, default: nil},
        routes:         {type: :array, of: :string, default: []},
        ports:          {type: :array, of: :string, default: []},
        writable_dirs:  {type: :array, of: :string, default: []},
        writable_files: {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:      {type: :hash, default: {}},
        local_only:     {type: :on_off, default: nil},
        cron:           BOXFILE_CRON_DEFAULTS
      }
    }

    BOXFILE_WORKER_STRING_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        cwd:            {type: :string, default: nil},
        start:          {type: :string, default: nil},
        stop:           {type: :string, default: nil},
        stop_timeout:   {type: :integer, default: nil},
        stop_force:     {type: :boolean, default: nil},
        writable_dirs:  {type: :array, of: :string, default: []},
        writable_files: {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:      {type: :hash, default: {}},
        local_only:     {type: :on_off, default: nil},
        cron:           BOXFILE_CRON_DEFAULTS
      }
    }

    BOXFILE_WEB_ARRAY_STRING_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :array, of: :string, default: []},
        routes:         {type: :array, of: :string, default: []},
        ports:          {type: :array, of: :string, default: []},
        writable_dirs:  {type: :array, of: :string, default: []},
        writable_files: {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:      {type: :hash, default: {}},
        local_only:     {type: :on_off, default: nil},
        cron:           BOXFILE_CRON_DEFAULTS
      }
    }

    BOXFILE_WORKER_ARRAY_STRING_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        start:          {type: :array, of: :string, default: []},
        writable_dirs:  {type: :array, of: :string, default: []},
        writable_files: {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:      {type: :hash, default: {}},
        local_only:     {type: :on_off, default: nil},
        cron:           BOXFILE_CRON_DEFAULTS
      }
    }

    BOXFILE_WEB_HASH_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        cwd:            {type: :hash, default: nil},
        start:          {type: :hash, default: {}},
        stop:           {type: :hash, default: {}},
        stop_timeout:   {type: :hash, default: {}},
        stop_force:     {type: :hash, default: {}},
        routes:         {type: :array, of: :string, default: []},
        ports:          {type: :array, of: :string, default: []},
        writable_dirs:  {type: :array, of: :string, default: []},
        writable_files: {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:      {type: :hash, default: {}},
        local_only:     {type: :on_off, default: nil},
        cron:           BOXFILE_CRON_DEFAULTS
      }
    }

    BOXFILE_WORKER_HASH_DEFAULTS = {
      type: :hash,
      default: {},
      template: {
        image:          {type: :string, default: nil},
        cwd:            {type: :hash, default: nil},
        start:          {type: :hash, default: {}},
        stop:           {type: :hash, default: {}},
        stop_timeout:   {type: :hash, default: {}},
        stop_force:     {type: :hash, default: {}},
        writable_dirs:  {type: :array, of: :string, default: []},
        writable_files: {type: :array, of: :string, default: []},
        network_dirs:   {type: :hash, default: {}},
        log_watch:      {type: :hash, default: {}},
        local_only:     {type: :on_off, default: nil},
        cron:           BOXFILE_CRON_DEFAULTS
      }
    }

    BOXFILE_DATA_VALIDATOR = {
      image:           { types: [:string], required: true },
      config:          { types: [:hash] },
      cron:            { types: [:array_of_hashes] },
      extra_packages:  { types: [:array_of_strings] },
      extra_path_dirs: { types: [:array_of_strings] },
      extra_steps:     { types: [:string, :array_of_strings] },
      local_only:      { types: [:boolean] }
    }

    BOXFILE_RUN_VALIDATOR = {
      "engine.config": { types: [:hash] },
      engine:          { types: [:string], required: true },
      image:           { types: [:string] },
      cache_dirs:      { types: [:array_of_strings] },
      extra_packages:  { types: [:array_of_strings] },
      dev_packages:    { types: [:array_of_strings] },
      extra_path_dirs: { types: [:array_of_strings] },
      extra_steps:     { types: [:string, :array_of_strings] },
      cwd:             { types: [:string] },
      fs_watch:        { types: [:boolean] },
      build_triggers:  { types: [:array_of_strings] }
    }

    BOXFILE_DEPLOY_VALIDATOR = {
      deploy_hook_timeout: { types: [:integer] },
      transform:           { types: [:string, :array_of_strings] },
      extra_steps:         { types: [:string, :array_of_strings] },
      before_live:         { types: [:hash] },
      before_live_all:     { types: [:hash] },
      after_live:          { types: [:hash] },
      after_live_all:      { types: [:hash] }
    }

    BOXFILE_WEB_VALIDATOR = {
      image:          { types: [:string] },
      cwd:            { types: [:string, :hash] },
      start:          { types: [:string, :array_of_strings, :hash], required: true },
      stop:           { types: [:string, :hash], required: false },
      stop_timeout:   { types: [:integer, :hash], required: false },
      stop_force:     { types: [:boolean, :hash], required: false },
      routes:         { types: [:array_of_strings] },
      ports:          { types: [:array_of_strings] },
      cron:           { types: [:array_of_hashes] },
      log_watch:      { types: [:hash] },
      network_dirs:   { types: [:hash] },
      writable_dirs:  { types: [:array_of_strings] },
      local_only:     { types: [:boolean] }
    }

    BOXFILE_WORKER_VALIDATOR = {
      image:          { types: [:string] },
      cwd:            { types: [:string, :hash] },
      start:          { types: [:string, :array_of_strings, :hash], required: true },
      stop:           { types: [:string, :hash], required: false },
      stop_timeout:   { types: [:integer, :hash], required: false },
      stop_force:     { types: [:boolean, :hash], required: false },
      routes:         { types: [:array_of_strings] },
      cron:           { types: [:array_of_hashes] },
      log_watch:      { types: [:hash] },
      network_dirs:   { types: [:hash] },
      writable_dirs:  { types: [:array_of_strings] },
      local_only:     { types: [:boolean] }
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
        when /^run\.config$/
          build_errors = validate_section(value, BOXFILE_RUN_VALIDATOR)
          if build_errors != {}
            errors[key] = build_errors
          end
        when /^deploy\.config$/
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
          if not value[:ports].nil? and value[:ports].is_a? Array
            value[:ports].each do |port|
              if not port.to_s =~ /^(\d{1,5}|\d{1,5}:\d{1,5}|tcp:\d{1,5}:\d{1,5}|udp:\d{1,5}:\d{1,5})$/
                web_errors[:ports] = "Invalid port format - #{port}"
                break
              end
            end
          end
          if value[:start].is_a? String
            if (value[:cwd] && ! value[:cwd].is_a?(String))
              web_errors[:cwd] = "cwd needs to be a string"
            end
            if (value[:stop] && ! value[:stop].is_a?(String))
              web_errors[:stop] = "stop needs to be a string"
            end
            if (value[:stop_timeout] && ! value[:stop_timeout].is_a?(Integer))
              web_errors[:stop_timeout] = "stop_timeout needs to be an integer"
            end
            if (value[:stop_force] && ! (value[:stop_force].is_a?(TrueClass) || value[:stop_force].is_a?(FalseClass)))
              web_errors[:stop_force] = "stop_force needs to be true or false"
            end
          elsif value[:start].is_a? Array
            [:cwd, :stop, :stop_timeout, :stop_force].each do |i|
              if value[i]
                web_errors[i] = "#{i} is invalid when start is an array, convert to hash syntax"
              end
            end
          elsif value[:start].is_a? Hash
            if value[:cwd]
              if value[:cwd].is_a?(Hash)
                value[:cwd].each_pair do |k, v|
                  if not value[:start][k]
                    web_errors["cwd_#{k}".to_sym] = "cwd #{k} needs a matching key in start"
                  end
                  if not v.is_a?(String)
                    web_errors["cwd_#{k}_value".to_sym] = "cwd #{k} value should be a string"
                  end
                end
              else
                web_errors[:cwd] = "cwd needs to be a hash"
              end
            end
            if value[:stop]
              if value[:stop].is_a?(Hash)
                value[:stop].each_pair do |k, v|
                  if not value[:start][k]
                    web_errors["stop_#{k}".to_sym] = "stop #{k} needs a matching key in start"
                  end
                  if not v.is_a?(String)
                    web_errors["stop_#{k}_value".to_sym] = "stop #{k} value should be a string"
                  end
                end
              else
                web_errors[:stop] = "stop needs to be a hash"
              end
            end
            if value[:stop_timeout]
              if value[:stop_timeout].is_a?(Hash)
                value[:stop_timeout].each_pair do |k, v|
                  if not value[:start][k]
                    web_errors["stop_timeout_#{k}".to_sym] = "stop_timeout #{k} needs a matching key in start"
                  end
                  if not v.is_a?(Integer)
                    web_errors["stop_timeout_#{k}_value".to_sym] = "stop_timeout #{k} value should be an integer"
                  end
                end
              else
                web_errors[:stop_timeout] = "stop_timeout needs to be a hash"
              end
            end
            if value[:stop_force]
              if value[:stop_force].is_a?(Hash)
                value[:stop_force].each_pair do |k, v|
                  if not value[:start][k]
                    web_errors["stop_force_#{k}".to_sym] = "stop_force #{k} needs a matching key in start"
                  end
                  if ! (v.is_a?(TrueClass) || v.is_a?(FalseClass))
                    web_errors["stop_force_#{k}_value".to_sym] = "stop_force #{k} value should be a string"
                  end
                end
              else
                web_errors[:stop_force] = "stop_force needs to be a hash"
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
                worker_errors[:cron] = "Invalid cron format"
                break
              end
            end
          end
          if value[:start].is_a? String
            if (value[:cwd] && ! value[:cwd].is_a?(String))
              worker_errors[:cwd] = "cwd needs to be a string"
            end
            if (value[:stop] && ! value[:stop].is_a?(String))
              worker_errors[:stop] = "stop needs to be a string"
            end
            if (value[:stop_timeout] && ! value[:stop_timeout].is_a?(Integer))
              worker_errors[:stop_timeout] = "stop_timeout needs to be an integer"
            end
            if (value[:stop_force] && ! (value[:stop_force].is_a?(TrueClass) || value[:stop_force].is_a?(FalseClass)))
              worker_errors[:stop_force] = "stop_force needs to be true or false"
            end
          elsif value[:start].is_a? Array
            [:cwd, :stop, :stop_timeout, :stop_force].each do |i|
              if value[i]
                worker_errors[i] = "#{i} is invalid when start is an array, convert to hash syntax"
              end
            end
          elsif value[:start].is_a? Hash
            if value[:cwd]
              if value[:cwd].is_a?(Hash)
                value[:cwd].each_pair do |k, v|
                  if not value[:start][k]
                    worker_errors["cwd_#{k}".to_sym] = "cwd #{k} needs a matching key in start"
                  end
                  if not v.is_a?(String)
                    worker_errors["cwd_#{k}_value".to_sym] = "cwd #{k} value should be a string"
                  end
                end
              else
                worker_errors[:cwd] = "cwd needs to be a hash"
              end
            end
            if value[:stop]
              if value[:stop].is_a?(Hash)
                value[:stop].each_pair do |k, v|
                  if not value[:start][k]
                    worker_errors["stop_#{k}".to_sym] = "stop #{k} needs a matching key in start"
                  end
                  if not v.is_a?(String)
                    worker_errors["stop_#{k}_value".to_sym] = "stop #{k} value should be a string"
                  end
                end
              else
                worker_errors[:stop] = "stop needs to be a hash"
              end
            end
            if value[:stop_timeout]
              if value[:stop_timeout].is_a?(Hash)
                value[:stop_timeout].each_pair do |k, v|
                  if not value[:start][k]
                    worker_errors["stop_timeout_#{k}".to_sym] = "stop_timeout #{k} needs a matching key in start"
                  end
                  if not v.is_a?(Integer)
                    worker_errors["stop_timeout_#{k}_value".to_sym] = "stop_timeout #{k} value should be an integer"
                  end
                end
              else
                worker_errors[:stop_timeout] = "stop_timeout needs to be a hash"
              end
            end
            if value[:stop_force]
              if value[:stop_force].is_a?(Hash)
                value[:stop_force].each_pair do |k, v|
                  if not value[:start][k]
                    worker_errors["stop_force_#{k}".to_sym] = "stop_force #{k} needs a matching key in start"
                  end
                  if ! (v.is_a?(TrueClass) || v.is_a?(FalseClass))
                    worker_errors["stop_force_#{k}_value".to_sym] = "stop_force #{k} value should be a string"
                  end
                end
              else
                worker_errors[:stop_force] = "stop_force needs to be a hash"
              end
            end
          end
          if worker_errors != {}
            errors[key] = worker_errors
          end
        when /^data\./
          data_errors = validate_section(value, BOXFILE_DATA_VALIDATOR)
          if not value[:cron].nil? and value[:cron].is_a? Array
            value[:cron].each do |cron|
              errors = validate_section(cron, BOXFILE_CRON_VALIDATOR)
              if errors != {}
                data_errors[:cron] = "Invalid cron format"
                break
              end
            end
          end
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
        if key =~ /^deploy.config$/
          value.each_pair do |k2, v2|
            if k2 =~ /(before|after)_live($|_all$)/
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
        # Tell users when they are using old nodes
        if ["dev", "code.build", "code.deploy"].include? key
          errors[key] = 'Deprecated node'
        end
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
      # Add default nodes for the run.config, deploy.config,
      # and dev nodes
      template[:'run.config'] = BOXFILE_RUN_DEFAULTS
      template[:'deploy.config'] = BOXFILE_DEPLOY_DEFAULTS
      template[:'deploy.config'][:template][:before_live] = boxfile_deploy_hooks_defaults(boxfile)
      template[:'deploy.config'][:template][:before_live_all] = boxfile_deploy_hooks_defaults(boxfile)
      template[:'deploy.config'][:template][:after_live] = boxfile_deploy_hooks_defaults(boxfile)
      template[:'deploy.config'][:template][:after_live_all] = boxfile_deploy_hooks_defaults(boxfile)
      # Step through the boxfile and add validation for
      # code and data nodes.
      boxfile.keys.each do |key|
        case key
        when /^data\./
          template[key] = BOXFILE_DATA_DEFAULTS
        when /^run\.config$/
        when /^deploy\.config$/
        when /^dev$/
        when /^web\./
          if boxfile[key][:start].nil?
            # add error?
          elsif boxfile[key][:start].is_a? Hash
            template[key] = BOXFILE_WEB_HASH_DEFAULTS
          elsif boxfile[key][:start].is_a? String
            template[key] = BOXFILE_WEB_STRING_DEFAULTS
          elsif boxfile[key][:start].is_a? Array
            template[key] = BOXFILE_WEB_ARRAY_STRING_DEFAULTS
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
          elsif boxfile[key][:start].is_a? Array
            template[key] = BOXFILE_WORKER_ARRAY_STRING_DEFAULTS       
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

    # check to see if boxfile.yml contains legacy configuration
    def boxfile_has_legacy_config(boxfile)
      
      # look for old keys
      boxfile.keys.each do |key|
        if ["dev", "code.build", "code.deploy"].include? key
          return true
        end
      end
      
      false
    end

  end
end
