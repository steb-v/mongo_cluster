require_relative 'security'
require_relative 'replica_set'
require_relative '../helpers/external_executable'

module MongoCluster
  module Shell
    extend ExternalExecutable

    def self.eval(cmd, host: 'localhost', port: ReplicaSet.settings.port)
      shell_command = generate_shell_command(host, port, cmd)
      concat_login_flags(shell_command) unless Security.allow_anonymous?
      run(shell_command)
    end

    def self.login?
      generate_shell_command('localhost', ReplicaSet.settings.port, 'db.getName()')
          .concat(login_flags)
          .tap {|shell_command| run(shell_command)}
      true
    rescue
      false
    end

    def self.concat_login_flags(shell_command)
      shell_command.concat(login_flags)
    end

    private

    def self.generate_shell_command(host, port, cmd)
      format('mongo admin --host %s --port %s --quiet --eval \'%s\'',host, port, cmd)
    end

    def self.login_flags
      format(' --username %s --password %s --authenticationDatabase admin', Security.settings.username, Security.settings.password)
    end

  end
end