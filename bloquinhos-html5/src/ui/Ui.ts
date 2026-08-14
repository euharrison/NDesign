import { formatClock, pad2 } from '../game/core/geometry';
import type { Game, GameEvent, GameState } from '../game/Game';

type DialogName = 'won' | 'lost' | 'finished' | 'levels' | 'help';

const query = <T extends Element>(selector: string, root: ParentNode = document): T => {
  const element = root.querySelector<T>(selector);
  if (!element) throw new Error(`Missing element: ${selector}`);
  return element;
};

/** The DOM layer: HUD, toolbar, level picker and the modal cards. */
export class Ui {
  private readonly overlay = query<HTMLElement>('[data-overlay]');
  private readonly dialogs = new Map<DialogName, HTMLElement>();
  private openDialog: DialogName | null = null;

  constructor(private readonly game: Game) {
    for (const name of ['won', 'lost', 'finished', 'levels', 'help'] as const) {
      this.dialogs.set(name, query<HTMLElement>(`[data-dialog="${name}"]`));
    }

    this.bindActions();
    this.bindPasswordForm();
    this.bindKeyboard();

    game.subscribe(this.onGameEvent);

    this.syncLevel();
    this.syncClock();
  }

  private bindActions(): void {
    const actions: Record<string, () => void> = {
      retry: () => {
        this.hideOverlay();
        this.game.retry();
      },
      'retry-dialog': () => {
        this.hideOverlay();
        this.game.retry();
      },
      next: () => {
        this.hideOverlay();
        this.game.next();
      },
      restart: () => {
        this.hideOverlay();
        this.game.goTo(this.game.packIndex, 0);
      },
      levels: () => {
        this.renderLevelPicker();
        this.show('levels');
      },
      help: () => this.show('help'),
      close: () => this.hideOverlay(),
    };

    for (const button of document.querySelectorAll<HTMLButtonElement>('[data-action]')) {
      const action = actions[button.dataset.action ?? ''];
      if (action) button.addEventListener('click', action);
    }
  }

  private bindPasswordForm(): void {
    const form = query<HTMLFormElement>('[data-password-form]');
    const input = query<HTMLInputElement>('#password-input');
    const error = query<HTMLElement>('[data-password-error]');

    form.addEventListener('submit', (event) => {
      event.preventDefault();

      if (this.game.enterPassword(input.value)) {
        input.value = '';
        error.hidden = true;
        this.hideOverlay();
      } else {
        error.hidden = false;
      }
    });

    input.addEventListener('input', () => (error.hidden = true));
  }

  private bindKeyboard(): void {
    window.addEventListener('keydown', (event) => {
      if (event.target instanceof HTMLInputElement) return;

      const key = event.key.toLowerCase();

      if (key === 'r') {
        this.hideOverlay();
        this.game.retry();
      } else if (key === 'escape') {
        this.hideOverlay();
      } else if (key === '?') {
        this.show('help');
      } else if (key === 'enter' && this.openDialog === 'won') {
        this.hideOverlay();
        this.game.next();
      }
    });
  }

  private onGameEvent = (event: GameEvent): void => {
    switch (event.type) {
      case 'state':
        this.onStateChange(event.state);
        break;
      case 'level':
        this.syncLevel();
        break;
      case 'tick':
        this.syncClock();
        break;
    }
  };

  private onStateChange(state: GameState): void {
    switch (state) {
      case 'won':
        query<HTMLElement>('[data-won-time]').textContent =
          `Tempo até aqui: ${formatClock(this.game.elapsed)}`;
        this.show('won');
        break;

      case 'lost':
        this.show('lost');
        break;

      case 'finished': {
        const best = this.game.bestTime;
        const line = `Você terminou "${this.game.pack.title}" em ${formatClock(this.game.elapsed)}.`;
        query<HTMLElement>('[data-final-time]').textContent =
          best !== null && best < this.game.elapsed
            ? `${line} Seu melhor tempo é ${formatClock(best)}.`
            : line;
        this.show('finished');
        break;
      }

      case 'playing':
        break;
    }
  }

  private syncLevel(): void {
    query<HTMLElement>('[data-pack-title]').textContent = this.game.pack.title;
    query<HTMLElement>('[data-level-number]').textContent = pad2(this.game.levelIndex + 1);
    query<HTMLElement>('[data-level-name]').textContent = this.game.level.name;

    const password = query<HTMLElement>('[data-password]');
    const code = this.game.level.password;
    password.textContent = code ? `senha ${code}` : '';
    password.hidden = !code;
  }

  private syncClock(): void {
    query<HTMLElement>('[data-clock]').textContent = formatClock(this.game.elapsed);
  }

  private renderLevelPicker(): void {
    const packs = query<HTMLElement>('[data-packs]');
    const levels = query<HTMLElement>('[data-levels]');

    packs.replaceChildren(
      ...this.game.packs.map((pack, index) => {
        const button = document.createElement('button');
        button.type = 'button';
        button.textContent = pack.title;
        button.toggleAttribute('data-active', index === this.game.packIndex);
        button.addEventListener('click', () => {
          this.game.goTo(index, 0);
          this.renderLevelPicker();
        });
        return button;
      }),
    );

    levels.replaceChildren(
      ...this.game.pack.levels.map((level, index) => {
        const item = document.createElement('li');
        const button = document.createElement('button');

        button.type = 'button';
        button.textContent = pad2(index + 1);
        button.title = level.name;
        button.toggleAttribute('data-current', index === this.game.levelIndex);
        button.addEventListener('click', () => {
          this.game.goTo(this.game.packIndex, index);
          this.hideOverlay();
        });

        item.append(button);
        return item;
      }),
    );
  }

  private show(name: DialogName): void {
    for (const [key, element] of this.dialogs) element.hidden = key !== name;
    this.overlay.hidden = false;
    this.openDialog = name;
  }

  private hideOverlay(): void {
    this.overlay.hidden = true;
    this.openDialog = null;
    for (const element of this.dialogs.values()) element.hidden = true;
  }
}
