#!/bin/bash

create_keys () {
  (umask 077 && ssh-keygen -q -N "" -t rsa -b 4096 -f "${1}/id_rsa" -C ${2} \
  && ssh-keygen -q -N "" -t ed25519  -f "${1}/id_ed25519" -C ${2})
}

print_keys () {

  ssh-keygen -l -f "${1}/id_rsa.pub"
  ssh-keygen -l -f "${1}/id_ed25519.pub"

}

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

main () {
  local tmp_dir=$(mktemp -d)

  if ! create_keys "${tmp_dir}" lain@anon; then
    echo "Unable to create SSH keys"
	exit 1
  fi

  echo "Session Dir: ${tmp_dir}"
  print_keys "${tmp_dir}"

  echo " !!! YOUR ~/.ssh/config WILL BE USED, ADD -F /dev/null !!! "

  if confirm ; then 
    ssh  -i $tmp_dir/id_rsa -i $tmp_dir/id_ed25519  "$@"
  fi

  rm -r $tmp_dir

  if [ -d $tmp_dir ] ; then 
    echo "Couldn't remove $tmp_dir, please check manually!"
  fi
}

main "$@"
