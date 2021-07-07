package appshield.kubernetes.KSV006

import data.lib.kubernetes

name = input.metadata.name

default checkDockerSocket = false

__rego_metadata__ := {
	"id": "KSV006",
	"title": "docker.sock is mounted to container",
	"version": "v1.0.0",
	"severity": "HIGH",
	"type": "Kubernetes Security Check",
	"description": "Mounting docker.sock from the host can give the container full root access to the host.",
	"recommended_actions": "Do not specify /var/run/docker.socket in 'spec.template.volumes.hostPath.path'.",
	"url": "https://kubesec.io/basics/spec-volumes-hostpath-path-var-run-docker-sock/",
}

__rego_input__ := {
	"combine": false,
	"selector": [{"type": "kubernetes"}],
}

# checkDockerSocket is true if volumes.hostPath.path is set to /var/run/docker.sock
# and is false if volumes.hostPath is set to some other path or not set.
checkDockerSocket {
	volumes := kubernetes.volumes
	volumes[_].hostPath.path == "/var/run/docker.sock"
}

deny[res] {
	checkDockerSocket

	# msg = sprintf("%s should not mount /var/run/docker.socker", [name])

	msg := kubernetes.format(sprintf("'%s' '%s' in '%s' namespace should not specify /var/run/docker.socker in spec.template.volumes.hostPath.path", [lower(kubernetes.kind), kubernetes.name, kubernetes.namespace]))

	res := {
		"msg": msg,
		"id": __rego_metadata__.id,
		"title": __rego_metadata__.title,
		"severity": __rego_metadata__.severity,
		"type": __rego_metadata__.type,
	}
}
