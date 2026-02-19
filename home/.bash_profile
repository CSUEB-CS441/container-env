if test -f /run/host-services/ssh-auth.sock; then
  sudo chown cs441-user:cs441-user /run/host-services/ssh-auth.sock
fi
. ~/.bashrc
. "/opt/rust/env"
