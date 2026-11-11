{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  flask,
}:
buildPythonPackage (finalAttrs: {
  pname = "flask-htmx";
  version = "0.4.0";
  pyproject = true;

  src = fetchPypi {
    pname = "flask_htmx";
    inherit (finalAttrs) version;
    hash = "sha256-LTZ/snyNqZ0DGgxWa35WJjcTlyLi1OjsZ8f5Qa3bIv0=";
  };

  # poetry-core renders `||` as a Requires-Dist that packaging >= 26 rejects.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'Flask = "^2.0.2 || ^3.0.0"' 'Flask = ">=2.0.2,<4.0.0"'
  '';

  build-system = [poetry-core];

  dependencies = [flask];

  pythonImportsCheck = ["flask_htmx"];

  meta = {
    description = "Flask extension to work with HTMX";
    homepage = "https://github.com/edmondchuc/flask-htmx";
    license = lib.licenses.mit;
    maintainers = [];
  };
})
