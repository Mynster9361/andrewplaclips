function Get-APlaAudio {
	<#
	.SYNOPSIS
		Retrieves available Andrew Pla audio clips from the module's data directory.

	.DESCRIPTION
		Returns the full path to a specific audio file when -AudioName is provided,
		or lists the base names of all available .wav files in the module's data folder.

	.PARAMETER AudioName
		The name of the audio clip (without the .wav extension) to retrieve the full path for.
		If omitted, all available clip names are returned.

	.EXAMPLE
		Get-APlaAudio

		Returns the base names of all available audio clips.

	.EXAMPLE
		Get-APlaAudio -AudioName 'FAFOFTW'

		Returns the full path to FAFOFTW.wav.
	#>
	[CmdletBinding()]
	[Alias('Get-APla')]
	[OutputType([string])]
	param(
		[Parameter(Mandatory = $false)]
		[string]$AudioName
	)

	$audioDir = Join-Path -Path $script:ModuleRoot -ChildPath 'data'
	if ($AudioName) {
		$AudioName += '.wav'
		$audioFile = Join-Path -Path $audioDir -ChildPath $AudioName
		return $audioFile
	}
	else {
		return $(Get-ChildItem -Path $audioDir -Filter '*.wav').BaseName
	}
}