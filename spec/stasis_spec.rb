require 'spec_helper'

describe Stasis do
  # Root directory, subdirectory
    # index.html.haml
    # layout.html.haml
    # rename.html.haml
    # rename_controller.html.haml
    # rename_action.html.haml
    # rename_to_subdirectory.html.haml
    # _partial.html.haml
    # subdirectory/
      # index.html.haml
      # layout.html.haml
      # rename_controller.html.haml
      # rename_action.html.haml
      # rename_to_root.html.haml
      # _partial.html.haml
  # Before
    # Verify class variable is set
  # Destination
    # Set in controller (rename_controller.html.haml)
    # Set in action (rename_action.html.haml)
    # Verify subdirectory can write to root directory (rename_to_root.html.haml)
    # Verify root can write to root directory (rename_to_subdirectory.html.haml)
  # Helper
    # Set in controller
    # Verify produces correct output
  # Ignore
    # Set in controller
    # Verify files are ignored
  # Layout
    # Set in controller (layout.html.haml)
    # Set in action (layout.html.haml)
  # Priority
    # Before, after writes to file
    # Verify order is correct
  # Render
    # Test render from action
    # Test render from view

  # TODO: test directory with no controller
end