package appshield.DS006

__rego_metadata__ := {
	"id": "DS006",
	"title": "COPY '--from' references current image FROM alias",
	"version": "v1.0.0",
	"severity": "CRITICAL",
	"type": "Dockerfile Security Check",
	"description": "COPY '--from' should not mention the current FROM alias, since it is impossible to copy from itself",
	"recommended_actions": "Don't use from flag",
	"url": "https://docs.docker.com/develop/develop-images/multistage-build/",
}

__rego_input__ := {
	"combine": "false",
	"selector": [{"type": "dockerfile"}],
}

get_alias_from_copy[args] {
	some i, j, name
	input.stages[name][i].Cmd == "copy"

	cmd := input.stages[name][i]

	contains(cmd.Flags[j], "--from=")
	parts := split(cmd.Flags[j], "=")

	is_alias_current_from_alias(name, parts[1])
	args := parts[1]
}

is_alias_current_from_alias(current_name, current_alias) = allow {
	current_name_lower := lower(current_name)
	current_alias_lower := lower(current_alias)

	#expecting stage name as "myimage:tag as dep"
	[_, alias] := regex.split(`\s+as\s+`, current_name_lower)

	alias == current_alias

	allow = true
}

deny[res] {
	args := get_alias_from_copy[_]
	res := sprintf("COPY from shouldn't mention current alias '%s'", [args])
}