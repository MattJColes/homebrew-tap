class Lgtmaybe < Formula
  include Language::Python::Virtualenv

  desc "Provider-agnostic pull request reviewer with keyless cloud auth"
  homepage "https://lgtmaybe.coles.codes/"
  url "https://files.pythonhosted.org/packages/d6/07/653e0239aa293ad82fe36bc346d3800bf2ba3efb59af83d08a89a3d9dbba/lgtmaybe-2.8.4.tar.gz"
  sha256 "64afdf9400e72564f54b5aa52b97a1550a988ee92f650bbe760eb9f47c7a4742"
  license "MIT"

  # The dependency wheels ship prebuilt extension dylibs (e.g. jiter) whose
  # install names use @rpath and lack header padding, so Homebrew cannot rewrite
  # them to an absolute path ("Failed to fix install linkage"). Preserve the
  # @rpath ids — they resolve correctly from the venv's fixed location anyway.
  preserve_rpath

  depends_on "ast-grep"
  depends_on "python@3.12"

  def install
    # lgtmaybe's dependency tree includes Rust extensions (tokenizers, hf-xet,
    # and litellm >= 1.92, itself a compiled package — Linux-only wheels at
    # 1.92, cp310-abi3 wheels covering macOS from 1.101.0) whose sdists
    # cannot build inside Homebrew's sandbox (no Cargo), so install lgtmaybe
    # and its dependencies from upstream PyPI wheels into an isolated
    # virtualenv. --prefer-binary makes pip back off to the newest version
    # that has a macOS-compatible wheel instead of grabbing a newer sdist it
    # would then fail to compile. The venv is created plainly so ensurepip
    # provides pip.
    system "python3.12", "-m", "venv", libexec
    system libexec/"bin/python", "-m", "pip", "install", "--prefer-binary",
           "lgtmaybe==#{version}"
    bin.install_symlink libexec/"bin/lgtmaybe"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/lgtmaybe --help")
  end
end
