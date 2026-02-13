{
  createScript,
}:

createScript "qute-fake-fullscreen" ./fake-fullscreen.sh {
  meta.description = "Enter fullscreen mode on a website while keeping qutebrowser windowed";
}
