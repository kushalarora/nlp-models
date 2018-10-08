test       = modules
COVERAGE  := $(addprefix --cov=, $(test))
PYTHONPATH = allennlp

.PHONY : clean
clean :
	@find . \
		| grep -E "(__pycache__|\.mypy_cache|\.pytest_cache|\.pyc|\.pyo$$)" \
		| xargs rm -rf
	@rm -rf $(MODEL_DIRS)

#
# Testing commands.
#

.PHONY : typecheck
typecheck :
	@echo "Typechecks: mypy"
	@PYTHONPATH=$(PYTHONPATH) mypy $(test) --ignore-missing-imports

.PHONY : lint
lint :
	@echo "Lint: pydocstyle"
	@pydocstyle --config=.pydocstyle $(test)
	@echo "Lint: pylint"
	@PYTHONPATH=$(PYTHONPATH) pylint --rcfile=.pylintrc -f colorized $(test)

.PHONY : unit-test
unit-test :
	@echo "Unit tests: pytest"
ifeq ($(suffix $(test)),.py)
	PYTHONPATH=$(PYTHONPATH) python -m pytest -v --color=yes $(test)
else
	PYTHONPATH=$(PYTHONPATH) python -m pytest -v --cov-config .coveragerc $(COVERAGE) --color=yes $(test)
endif

.PHONY : test
test : typecheck lint unit-test

#
# Git helpers.
#

.PHONY: create-branch
create-branch :
	git checkout -b ISSUE=$(issue)
	git push --set-upstream origin ISSUE=$(issue)