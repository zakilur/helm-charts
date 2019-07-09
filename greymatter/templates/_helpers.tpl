{{- /* envvars loops through the global sidecar envvars and generates Kubernetes container env keys for both regular values and secrets from the local sidecar values and from the global values as a backup */}}
{{- define "greymatter.envvars" }}
  {{- $top := . }}
    {{- range $name, $envvar := .Values.global.sidecar.envvars }}
          {{- $envName := $name | upper | replace "." "_" | replace "-" "_" }}
          {{- $l := "" }}
          {{- if $top.Values.sidecar.envvars }}
            {{- $l = index $top.Values.sidecar.envvars $name }}
          {{- end}}
          {{- $e := $l | default $envvar }}
          {{- if eq $e.type "secret" }}
          - name: {{ $envName }}
            valueFrom:
            secretKeyRef:
            name: {{ $e.secret }}
            key: {{ $e.key }}
          {{- else if eq $e.type "value" }}
          {{- /* The following removes any undefined values. At this stage, it means both the local and global values are undefined, so its best to just get rid of it */}}
          {{- if (tpl $e.value $) ne "" }}
          - name: {{ $envName }}
            value: {{ tpl $e.value $ | quote }}
          {{- end }}
          {{- end }}
    {{- end }}
{{- end }}