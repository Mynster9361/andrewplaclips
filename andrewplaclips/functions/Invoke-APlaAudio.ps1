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

	.PARAMETER UseVlc
		Play the audio using VLC Media Player instead of the built-in SoundPlayer.
		VLC must be installed. The standard installation path is checked automatically.
		You can override the path with -VlcPath.

	.PARAMETER VlcPath
		Full path to vlc.exe. Only used when -UseVlc is specified.
		Defaults to the standard VLC installation path.

	.EXAMPLE
		Invoke-APlaAudio -AudioName 'FAFOFTW'

		Plays the FAFOFTW.wav audio clip using the built-in SoundPlayer.

	.EXAMPLE
		Invoke-APlaAudio -AudioName 'GG' -UseVlc

		Plays GG.wav using VLC Media Player.

	.EXAMPLE
		Get-APlaAudio | ForEach-Object { Invoke-APlaAudio -AudioName $_ }

		Plays every available audio clip in sequence.
	#>
	[CmdletBinding()]
	[OutputType([string])]
	param(
		[Parameter(Mandatory = $true)]
		[string]$AudioName,

		[Parameter()]
		[switch]$UseVlc,

		[Parameter()]
		[string]$VlcPath = 'C:\Program Files\VideoLAN\VLC\vlc.exe'
	)

	$audioDir = Join-Path -Path $script:ModuleRoot -ChildPath 'data'
	$audioFile = Join-Path -Path $audioDir -ChildPath "$AudioName.wav"

	if (-not (Test-Path $audioFile)) {
		throw "Audio file not found: $audioFile"
	}

	if ($UseVlc) {
		if (-not (Test-Path $VlcPath)) {
			throw "VLC not found at '$VlcPath'. Install VLC or supply the correct path with -VlcPath."
		}

		$proc = Start-Process -FilePath $VlcPath `
			-ArgumentList @('--play-and-exit', '--intf', 'dummy', '--no-video', $audioFile) `
			-NoNewWindow -Wait -PassThru

		if ($proc.ExitCode -ne 0) {
			throw "VLC exited with code $($proc.ExitCode) while playing '$audioFile'."
		}
	}
	else {
		try {
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