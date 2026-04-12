$moduleRoot = (Resolve-Path "$global:testroot\..").Path

Describe "Invoke-APlaAudio" {
	BeforeAll {
		Import-Module "$moduleRoot\andrewplaclips\andrewplaclips.psd1" -Force

		# Create a temporary data directory with a minimal valid wav file for testing
		$script:tempDataDir = Join-Path -Path $TestDrive -ChildPath 'data'
		New-Item -Path $script:tempDataDir -ItemType Directory -Force | Out-Null

		# Write a minimal valid PCM WAV file (44-byte header, no audio data)
		$wavPath = Join-Path $script:tempDataDir 'GG.wav'
		$bytes = [byte[]](
			0x52, 0x49, 0x46, 0x46, # "RIFF"
			0x24, 0x00, 0x00, 0x00, # chunk size = 36
			0x57, 0x41, 0x56, 0x45, # "WAVE"
			0x66, 0x6D, 0x74, 0x20, # "fmt "
			0x10, 0x00, 0x00, 0x00, # subchunk size = 16
			0x01, 0x00,           # PCM format
			0x01, 0x00,           # mono
			0x44, 0xAC, 0x00, 0x00, # 44100 Hz
			0x88, 0x58, 0x01, 0x00, # byte rate
			0x02, 0x00,           # block align
			0x10, 0x00,           # bits per sample = 16
			0x64, 0x61, 0x74, 0x61, # "data"
			0x00, 0x00, 0x00, 0x00  # subchunk size = 0
		)
		[System.IO.File]::WriteAllBytes($wavPath, $bytes)

		# Point module root to TestDrive
		$module = Get-Module andrewplaclips
		& $module { $script:ModuleRoot = $args[0] } $TestDrive
	}

	AfterAll {
		Remove-Module andrewplaclips -ErrorAction Ignore
	}

	Context "When a valid AudioName is provided" {
		It "Returns a confirmation string containing the filename" {
			$result = Invoke-APlaAudio -AudioName 'GG'
			$result | Should -BeLike '*GG.wav'
		}
	}

	Context "When an invalid AudioName is provided" {
		It "Throws when the file does not exist" {
			{ Invoke-APlaAudio -AudioName 'doesnotexist' } | Should -Throw
		}

		It "Throw message mentions the missing file path" {
			{ Invoke-APlaAudio -AudioName 'doesnotexist' } | Should -Throw '*doesnotexist.wav*'
		}
	}

	Context "Parameter validation" {
		It "AudioName is a mandatory parameter" {
			$cmd = Get-Command Invoke-APlaAudio
			$param = $cmd.Parameters['AudioName']
			$param.Attributes.Where({ $_ -is [Parameter] }).Mandatory | Should -Be $true
		}
	}
}
