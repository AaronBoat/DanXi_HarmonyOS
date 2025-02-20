import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { GlobalContext } from '../common/utils/GlobalContext';
import Want from '@ohos.application.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log('[EntryAbility] onCreate');
    
    // Store global context
    GlobalContext.getContext().setObject('mainAbility', this);
  }

  onDestroy(): void {
    console.log('[EntryAbility] onDestroy');
    // Cleanup resources if needed
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page to SplashPage
    windowStage.loadContent('pages/SplashPage', (err: Error | null) => {
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
