$moduleRoot = (Resolve-Path "$global:testroot\..").Path

Describe "Get-APlaAudio" {
	BeforeAll {
		# Ensure module is loaded
		Import-Module "$moduleRoot\andrewplaclips\andrewplaclips.psd1" -Force

		# Create a temporary data directory with fake wav files for testing
		$script:tempDataDir = Join-Path -Path $TestDrive -ChildPath 'data'
		New-Item -Path $script:tempDataDir -ItemType Directory -Force | Out-Null
		New-Item -Path (Join-Path $script:tempDataDir 'GG.wav') -ItemType File -Force | Out-Null
		New-Item -Path (Join-Path $script:tempDataDir 'bait.wav') -ItemType File -Force | Out-Null

		# Point the module's internal root to TestDrive so Get-APlaAudio picks up the temp files
		$module = Get-Module andrewplaclips
		& $module { $script:ModuleRoot = $args[0] } $TestDrive
	}

	AfterAll {
		Remove-Module andrewplaclips -ErrorAction Ignore
	}

	Context "When no AudioName is provided" {
		It "Returns all available clip base names" {
			$result = Get-APlaAudio
			$result | Should -Contain 'GG'
			$result | Should -Contain 'bait'
		}

		It "Returns only strings" {
			$result = Get-APlaAudio
			$result | ForEach-Object { $_ | Should -BeOfType [string] }
		}

		It "Does not include the .wav extension in the returned names" {
			$result = Get-APlaAudio
			$result | ForEach-Object { $_ | Should -Not -Match '\.wav$' }
		}
	}

	Context "When a valid AudioName is provided" {
		It "Returns the full path to the wav file" {
			$result = Get-APlaAudio -AudioName 'GG'
			$result | Should -BeLike '*GG.wav'
		}

		It "Returned path ends with .wav" {
			$result = Get-APlaAudio -AudioName 'bait'
			$result | Should -Match '\.wav$'
		}
	}
}
