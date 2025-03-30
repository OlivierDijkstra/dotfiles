#!/usr/bin/env bun
import {
  MouseProvider
} from '@zenobius/ink-mouse';
import { execa } from 'execa';
import { Box, render, useApp, useInput } from 'ink';
import React, { useState } from 'react';
import { Button, DismissButton } from './components/button';

// Define the menu options without emojis
const menuItems = [
  { label: 'Lock', action: 'lock', command: 'hyprlock' },
  { label: 'Suspend', action: 'suspend', command: 'systemctl suspend' },
  { label: 'Shutdown', action: 'shutdown', command: 'systemctl poweroff' },
  { label: 'Reboot', action: 'reboot', command: 'systemctl reboot' },
];

interface KeyPress {
  upArrow: boolean;
  downArrow: boolean;
  return: boolean;
  escape: boolean;
}

const App: React.FC = () => {
  const { exit } = useApp();
  const [selectedIndex, setSelectedIndex] = useState(0);

  // Handle keyboard input
  useInput((input: string, key: KeyPress) => {
    if (input === 'q' || key.escape) {
      process.exit(0);
    }

    if (key.upArrow || input === 'k') {
      setSelectedIndex((prev: number) => (prev > 0 ? prev - 1 : menuItems.length - 1));
    }

    if (key.downArrow || input === 'j') {
      setSelectedIndex((prev: number) => (prev < menuItems.length - 1 ? prev + 1 : 0));
    }

    if (key.return || input === ' ' || input === 'Enter') {
      executeAction(selectedIndex);
    }

    // Support number keys for direct selection
    const numKey = parseInt(input, 10);
    if (!isNaN(numKey) && numKey >= 1 && numKey <= menuItems.length) {
      setSelectedIndex(numKey - 1);
    }
  });

  // Function to exit the app directly
  const handleExit = () => {
    console.log("Exiting...");
    process.exit(0);
  };

  // Execute the selected action
  const executeAction = async (index: number) => {
    const item = menuItems[index];
    try {
      console.log(`Executing: ${item.action}`);
      const [command, ...args] = item.command.split(' ');
      // Exit immediately after starting the command, don't wait for it to complete
      execa(command, args, { detached: true, stdio: 'ignore' });
      process.exit(0);
    } catch (error) {
      console.error(`Failed to execute ${item.action}:`, error);
      process.exit(1); // Also exit on error, but with error code
    }
  };

  return (
    <MouseProvider>
      <Box flexDirection="column">
        {/* Header with dismiss button in its own row */}
        <Box justifyContent="flex-end" alignItems="center" height={1} marginBottom={0}>
          <DismissButton onClick={handleExit} />
        </Box>

        {/* Main content - separate from header */}
        <Box 
          flexDirection="column" 
          paddingX={1}
          paddingY={0}
          minHeight={7}
          justifyContent="center"
          alignItems="stretch"
          width="100%"
        >  
          {menuItems.map((item, index) => (
            <Button 
              key={item.action} 
              label={item.label}
              isSelected={selectedIndex === index}
              onClick={() => executeAction(index)}
            />
          ))}
        </Box>
      </Box>
    </MouseProvider>
  );
};

// Render the app
render(<App />); 