function Invoke-APlaAudio {
	<#
	.SYNOPSIS
		Plays an Andrew Pla audio clip.

	.DESCRIPTION
		Plays the specified .wav audio clip from the module's data directory
		using the .NET SoundPlayer. Playback is synchronous — the function
		does not return until the clip has finished playing.

	.PARAMETER AudioName
		The name of the audio clip to play, without the .wav extension.
		Use Get-APlaAudio to list available clip names.

	.EXAMPLE
		Invoke-APlaAudio -AudioName 'FAFOFTW'
		Plays the FAFOFTW.wav audio clip.

	.EXAMPLE
		Get-APlaAudio | ForEach-Object { Invoke-APlaAudio -AudioName $_ }
		Plays every available audio clip in sequence.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$AudioName
	)

	$audioDir = Join-Path -Path $script:ModuleRoot -ChildPath 'data'
	$audioFile = Join-Path -Path $audioDir -ChildPath "$AudioName.wav"

	if (-not (Test-Path $audioFile)) {
		throw "Audio file not found: $audioFile"
	}

	try {
		$player = New-Object System.Media.SoundPlayer
		$player.SoundLocation = $audioFile
		$player.Load()
		$player.PlaySync()
		return "Played: $(Split-Path $audioFile -Leaf)"
	}
	catch {
		throw "Failed to play $audioFile`: $_"
	}
}