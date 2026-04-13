function Invoke-APlaAudio {
	<#
	.SYNOPSIS
		Plays an Andrew Pla audio clip.

	.DESCRIPTION
		Plays the specified .wav audio clip from the module's data directory.
		By default uses the built-in .NET SoundPlayer. Use -Random to play a
		randomly selected clip.

	.PARAMETER AudioName
		The name of the audio clip to play, without the .wav extension.
		Use Get-APlaAudio to list available clip names.

	.PARAMETER Random
		Plays a randomly selected audio clip from the available clips.

	.EXAMPLE
		Invoke-APlaAudio -AudioName 'FAFOFTW'

		Plays the FAFOFTW.wav audio clip using the built-in SoundPlayer.

	.EXAMPLE
		Invoke-APlaAudio -Random

		Plays a randomly selected audio clip.

	.EXAMPLE
		Get-APlaAudio | ForEach-Object { Invoke-APlaAudio -AudioName $_ }

		Plays every available audio clip in sequence.
	#>
	[CmdletBinding(DefaultParameterSetName = 'ByName')]
	[Alias('Play-APla')]
	[OutputType([string])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByName')]
		[ArgumentCompleter({ (Get-APlaAudio) })]
		[string]$AudioName,

		[Parameter(Mandatory = $true, ParameterSetName = 'Random')]
		[switch]$Random
	)

	if ($Random) {
		$AudioName = Get-APlaAudio | Get-Random
	}

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