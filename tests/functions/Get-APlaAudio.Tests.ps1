Describe "Get-APlaAudio" {
	BeforeAll {
		Import-Module "$global:testroot\..\andrewplaclips\andrewplaclips.psd1" -Force
	}

	AfterAll {
		Remove-Module andrewplaclips -ErrorAction Ignore
	}

	It "Returns a list of clip names when called with no arguments" {
		$result = Get-APlaAudio
		$result | Should -Not -BeNullOrEmpty
	}

	It "Returns strings without .wav extension" {
		$result = Get-APlaAudio
		$result | ForEach-Object { $_ | Should -Not -Match '\.wav$' }
	}

	It "Returns a file path when AudioName is provided" {
		$result = Get-APlaAudio -AudioName 'GG'
		$result | Should -BeLike '*GG.wav'
	}
}
