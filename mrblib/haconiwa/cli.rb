module Haconiwa
  module Cli
    def self.run(args)
      args.shift
      base, init = get_script_and_eval(args)
      base.run(*init)
    end

    def self.attach(args)
      opt = Argtable.new
      opt.integer('t', 'target', 'PID', "Container's PID to attatch.")
      opt.string('n', 'name', 'CONTAINER_NAME', "Container's name. Set if the name is dynamically defined")
      opt.string('A', 'allow', 'CAPS[,CAPS...]', "Capabilities to allow attached process. Independent container's own caps")
      opt.string('D', 'drop', 'CAPS[,CAPS...]', "Capabilities to drop from attached process. Independent container's own caps")
      opt.literal('h', 'help', "Show help")
      opt.enable_catchall('HACO_FILE [-- COMMAND...]', '', 32)
      e = opt.parse(args)

      if opt['h'].count > 0
        opt.glossary
        exit
      end

      if e > 0
        opt.glossary
        exit 1
      end

      base, exe = get_script_and_eval(opt.catchall.values)

      base.pid  = opt['t'].value if opt['t'].exist?
      base.name = opt['n'].value if opt['n'].exist?
      base.attached_capabilities = Capabilities.new
      if opt['A'].exist? or opt['D'].exist?
        base.attached_capabilities.allow(*opt['A'].value.split(',')) if opt['A'].exist?
        base.attached_capabilities.drop(*opt['D'].value.split(','))  if opt['D'].exist?
      end

      base.attach(*exe)
    end

    def self.revisions
      puts "mgem and mruby revisions:"
      puts "--------"
      puts Haconiwa.mrbgem_revisions.to_a.map{|a| sprintf "%-24s%s", *a }.join("\n")
    end

    private

    def self.get_script_and_eval(args)
      script = File.read(args[0])
      exe    = args[1..-1]
      if exe.first == "--"
        exe.shift
      end

      return [Kernel.eval(script), exe]
    end
  end
end
