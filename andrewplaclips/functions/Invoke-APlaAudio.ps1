function Invoke-APlaAudio {
	<#
	.SYNOPSIS
		Plays an Andrew Pla audio clip.

	.DESCRIPTION
		Plays the specified .wav audio clip from the module's data directory.
		By default uses the built-in .NET SoundPlayer. Use -UseVlc to play
		via VLC Media Player instead (requires VLC to be installed).

	.PARAMETER AudioName
		The name of the audio clip to play, without the .wav extension.
		Use Get-APlaAudio to list available clip names.

	.EXAMPLE
		Invoke-APlaAudio -AudioName 'FAFOFTW'

		Plays the FAFOFTW.wav audio clip using the built-in SoundPlayer.

	.EXAMPLE
		Get-APlaAudio | ForEach-Object { Invoke-APlaAudio -AudioName $_ }

		Plays every available audio clip in sequence.
	#>
	[CmdletBinding()]
	[OutputType([string])]
	param(
		[Parameter(Mandatory = $true, Position = 0)]
		[ArgumentCompleter({ (Get-APlaAudio) })]
		[string]$AudioName
	)

	$audioDir = Join-Path -Path $script:ModuleRoot -ChildPath 'data'
	$audioFile = Join-Path -Path $audioDir -ChildPath "$AudioName.wav"
	Write-Verbose "Attempting to play audio file: $audioFile"

	if (-not (Test-Path $audioFile)) {
		throw "Audio file not found: $audioFile"
	}

	if ($IsMacOS) {
		try {
			Write-Verbose "Using 'afplay' to play audio on macOS"
			afplay $audioFile
		}
		catch {
			throw "Failed to play $audioFile on macOS`: $_"
		}
	}
	else {
		try {
			Write-Verbose "Using System.Media.SoundPlayer to play audio on Windows"
			$player = New-Object System.Media.SoundPlayer
			$player.SoundLocation = $audioFile
			$player.Load()
			$player.PlaySync()
		}
		catch {
			throw "Failed to play $audioFile`: $_"
		}
	}

	return "Played: $(Split-Path $audioFile -Leaf)"
}