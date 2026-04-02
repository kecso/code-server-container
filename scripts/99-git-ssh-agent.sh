# Auto-load ssh-agent env after `setup-git-ssh` (until container restart).
# Sourced from /etc/profile (login) and /etc/bash.bashrc (interactive non-login).

if [ -z "${SSH_AUTH_SOCK:-}" ] && [ -f "${HOME}/.ssh/agent.env" ]; then
  # shellcheck source=/dev/null
  . "${HOME}/.ssh/agent.env"
fi

if [ -n "${SSH_AUTH_SOCK:-}" ]; then
  _ssh_agent_rc=0
  ssh-add -l >/dev/null 2>&1 || _ssh_agent_rc=$?
  if [ "$_ssh_agent_rc" -ne 0 ] && [ "$_ssh_agent_rc" -ne 1 ]; then
    unset SSH_AUTH_SOCK SSH_AGENT_PID
    rm -f "${HOME}/.ssh/agent.env" "${HOME}/.ssh/agent.sock" 2>/dev/null || true
  fi
  unset _ssh_agent_rc
fi
