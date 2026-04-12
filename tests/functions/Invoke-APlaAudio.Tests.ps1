$moduleRoot = (Resolve-Path "$global:testroot\..").Path

Describe "Invoke-APlaAudio" {
	BeforeAll {
		Import-Module "$moduleRoot\andrewplaclips\andrewplaclips.psd1" -Force

		# Create a temporary data directory with a minimal valid PCM WAV file
		$testDataDir = Join-Path $TestDrive 'data'
		New-Item -Path $testDataDir -ItemType Directory -Force | Out-Null
		$wavPath = Join-Path $testDataDir 'GG.wav'
		$bytes = [byte[]](
			0x52, 0x49, 0x46, 0x46,  # RIFF
			0x24, 0x00, 0x00, 0x00,  # chunk size = 36
			0x57, 0x41, 0x56, 0x45,  # WAVE
			0x66, 0x6D, 0x74, 0x20,  # fmt
			0x10, 0x00, 0x00, 0x00,  # subchunk size = 16
			0x01, 0x00,              # PCM
			0x01, 0x00,              # mono
			0x44, 0xAC, 0x00, 0x00,  # 44100 Hz
			0x88, 0x58, 0x01, 0x00,  # byte rate
			0x02, 0x00,              # block align
			0x10, 0x00,              # 16-bit
			0x64, 0x61, 0x74, 0x61,  # data
			0x00, 0x00, 0x00, 0x00   # data size = 0
		)
		[System.IO.File]::WriteAllBytes($wavPath, $bytes)

		# Point the module root to TestDrive using Pester v5 InModuleScope
		$testDriveValue = $TestDrive
		InModuleScope andrewplaclips -Parameters @{ Root = $testDriveValue } {
			param($Root)
			$script:ModuleRoot = $Root
		}
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
			$isMandatory = ($param.Attributes |
					Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
						Select-Object -First 1).Mandatory
			$isMandatory | Should -Be $true
		}
	}
}
