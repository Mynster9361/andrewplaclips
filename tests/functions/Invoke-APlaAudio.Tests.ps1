Describe "Invoke-APlaAudio" {
	BeforeAll {
		Import-Module "$global:testroot\..\andrewplaclips\andrewplaclips.psd1" -Force
	}

	AfterAll {
		Remove-Module andrewplaclips -ErrorAction Ignore
	}

	It "Plays a clip and returns a confirmation string" {
		$result = Invoke-APlaAudio -AudioName 'GG'
		$result | Should -BeLike '*GG.wav'
	}

	It "Throws when the audio file does not exist" {
		{ Invoke-APlaAudio -AudioName 'doesnotexist' } | Should -Throw
	}

	It "AudioName is a mandatory parameter" {
		$param = (Get-Command Invoke-APlaAudio).Parameters['AudioName']
		$isMandatory = ($param.Attributes |
				Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
					Select-Object -First 1).Mandatory
		$isMandatory | Should -Be $true
	}
}
