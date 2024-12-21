import { Ability } from '@ohos.application.Ability';
import window from '@ohos.window';
import { GlobalContext } from '../common/utils/GlobalContext';

export default class EntryAbility extends Ability {
  onCreate(want: Record<string, unknown>, launchParam: Record<string, unknown>): void {
    console.log('[EntryAbility] onCreate');
    
    // Store global context
    GlobalContext.getContext().setObject('mainAbility', this);
  }

  onDestroy(): void {
    console.log('[EntryAbility] onDestroy');
    // Cleanup resources if needed
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page
    windowStage.loadContent('pages/LoginPage', (err: Error | null) => {
      if (err) {
        console.error(`Failed to load the content. Cause: ${JSON.stringify(err)}`);
      }
    });
  }

  onWindowStageDestroy(): void {
    console.log('[EntryAbility] onWindowStageDestroy');
    // Perform cleanup when window stage is destroyed
  }

  onForeground(): void {
    console.log('[EntryAbility] onForeground');
  }

  onBackground(): void {
    console.log('[EntryAbility] onBackground');
  }
}
