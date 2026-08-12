import type { Game, GameEvent } from '../game/Game';
import type { PathType } from '../game/core/constants';
import { TOOLS, type Tool } from '../game/core/DrawController';
import { fillZero } from '../game/core/geometry';
import { RIDER_LABELS, RIDER_TYPES, type RiderType } from '../game/riders';

type DialogName = 'question' | 'transition' | 'final' | 'help' | 'rider';

const query = <T extends Element>(selector: string, root: ParentNode = document): T => {
  const element = root.querySelector<T>(selector);
  if (!element) throw new Error(`Missing element: ${selector}`);
  return element;
};

/**
 * The DOM layer: toolbar, HUD, progress dots and the modal cards. It only reads
 * the game's public state and calls its actions, so gameplay stays testable
 * without a browser.
 */
export class Ui {
  private readonly overlay = query<HTMLElement>('[data-overlay]');
  private readonly dialogs = new Map<DialogName, HTMLElement>();
  private readonly progress = query<HTMLElement>('[data-progress]');
  private openDialog: DialogName | null = null;

  constructor(private readonly game: Game) {
    for (const name of ['question', 'transition', 'final', 'help', 'rider'] as const) {
      this.dialogs.set(name, query<HTMLElement>(`[data-dialog="${name}"]`));
    }

    this.buildProgress();
    this.buildRiderPicker();
    this.bindToolbar();
    this.bindActions();
    this.bindColors();
    this.bindKeyboard();

    game.subscribe(this.onGameEvent);
    this.syncAll();
  }

  // ---------------------------------------------------------------- binding

  private bindToolbar(): void {
    for (const button of document.querySelectorAll<HTMLButtonElement>('[data-tool]')) {
      button.addEventListener('click', () => {
        this.game.tools.setTool(button.dataset.tool as Tool);
        this.syncToolbar();
      });
    }

    for (const button of document.querySelectorAll<HTMLButtonElement>('[data-line-type]')) {
      button.addEventListener('click', () => {
        this.game.tools.setLineType(Number(button.dataset.lineType) as PathType);
        this.syncToolbar();
      });
    }
  }

  private bindActions(): void {
    const actions: Record<string, () => void> = {
      begin: () => {
        this.hideOverlay();
        this.game.begin();
      },
      play: () => this.game.playState(),
      stop: () => this.game.stop(),
      undo: () => this.game.undo(),
      redo: () => this.game.redo(),
      replay: () => {
        this.hideOverlay();
        this.game.replay();
      },
      'redo-level': () => {
        this.hideOverlay();
        this.game.redo();
      },
      next: () => {
        this.hideOverlay();
        this.game.next();
      },
      restart: () => {
        this.hideOverlay();
        this.game.restart();
      },
      help: () => this.show('help'),
      rider: () => this.show('rider'),
      close: () => this.closeTransientDialog(),
    };

    for (const button of document.querySelectorAll<HTMLButtonElement>('[data-action]')) {
      const action = actions[button.dataset.action ?? ''];
      if (action) button.addEventListener('click', action);
    }
  }

  private bindColors(): void {
    for (const input of document.querySelectorAll<HTMLInputElement>('[data-color]')) {
      const key = input.dataset.color as 'shirt' | 'pants' | 'skin' | 'vehicle';
      input.value = this.game.palette[key];
      input.addEventListener('input', () => this.game.setPalette({ [key]: input.value }));
    }
  }

  private bindKeyboard(): void {
    const shortcuts: Record<string, Tool> = {
      p: 'pencil',
      l: 'line',
      e: 'erase',
      h: 'hand',
      z: 'zoom',
    };

    let toolBeforeSpace: Tool | null = null;

    window.addEventListener('keydown', (event) => {
      if (event.target instanceof HTMLInputElement) return;

      const key = event.key.toLowerCase();

      if (key === 'z' && (event.ctrlKey || event.metaKey)) {
        event.preventDefault();
        this.game.undo();
        return;
      }

      if (event.code === 'Space' && this.game.state === 'draw') {
        event.preventDefault();
        if (toolBeforeSpace === null) {
          toolBeforeSpace = this.game.tools.tool;
          this.game.tools.setTool('hand');
          this.syncToolbar();
        }
        return;
      }

      if (key === 'enter' && (this.game.state === 'draw' || this.game.state === 'pause')) {
        this.game.playState();
        return;
      }

      if (key === 'escape') {
        if (this.openDialog === 'help' || this.openDialog === 'rider') this.closeTransientDialog();
        else if (this.game.state === 'play') this.game.stop();
        return;
      }

      if (key === '?') {
        this.show('help');
        return;
      }

      const tool = shortcuts[key];
      if (tool && this.game.state === 'draw' && !event.ctrlKey && !event.metaKey) {
        this.game.tools.setTool(tool);
        this.syncToolbar();
      }
    });

    window.addEventListener('keyup', (event) => {
      if (event.code === 'Space' && toolBeforeSpace) {
        this.game.tools.setTool(toolBeforeSpace);
        toolBeforeSpace = null;
        this.syncToolbar();
      }
    });
  }

  // ------------------------------------------------------------------ views

  private buildProgress(): void {
    this.progress.replaceChildren(
      ...Array.from({ length: this.game.totalLevels }, () => document.createElement('li')),
    );
  }

  private buildRiderPicker(): void {
    const container = query<HTMLElement>('[data-riders]');

    container.replaceChildren(
      ...RIDER_TYPES.map((type) => {
        const button = document.createElement('button');
        button.type = 'button';
        button.textContent = RIDER_LABELS[type];
        button.dataset.rider = type;
        button.addEventListener('click', () => {
          this.game.setRiderType(type as RiderType);
          this.syncRiderPicker();
        });
        return button;
      }),
    );

    this.syncRiderPicker();
  }

  private syncRiderPicker(): void {
    for (const button of document.querySelectorAll<HTMLButtonElement>('[data-rider]')) {
      button.toggleAttribute('data-active', button.dataset.rider === this.game.riderType);
    }
  }

  private onGameEvent = (event: GameEvent): void => {
    switch (event.type) {
      case 'state':
        this.syncToolbar();
        if (event.state === 'init') this.show('question');
        break;

      case 'level':
        this.syncLevel();
        break;

      case 'won':
        if (event.last) {
          this.renderSummary();
          this.show('final');
        } else {
          query<HTMLElement>('[data-answer]').textContent = event.answer.replace(/-/g, ' ');
          this.show('transition');
        }
        this.syncProgress();
        break;

      case 'paths':
        this.syncToolbar();
        break;
    }
  };

  private syncAll(): void {
    this.syncLevel();
    this.syncToolbar();
    // The game reaches its first state before the UI subscribes, so catch up.
    if (this.game.state === 'init') this.show('question');
  }

  private syncLevel(): void {
    const number = fillZero(this.game.levelIndex + 1);
    for (const element of document.querySelectorAll('[data-level-number]')) {
      element.textContent = number;
    }
    for (const element of document.querySelectorAll('[data-question]')) {
      element.textContent = this.game.level.question;
    }

    this.syncProgress();
    this.syncRiderPicker();
  }

  private syncProgress(): void {
    [...this.progress.children].forEach((item, index) => {
      item.toggleAttribute('data-done', index < this.game.levelIndex);
      item.toggleAttribute('data-current', index === this.game.levelIndex);
    });
  }

  private syncToolbar(): void {
    const drawing = this.game.state === 'draw';
    const playing = this.game.state === 'play' || this.game.state === 'die';

    for (const button of document.querySelectorAll<HTMLButtonElement>('[data-tool]')) {
      button.toggleAttribute('data-active', button.dataset.tool === this.game.tools.tool);
      button.disabled = !drawing;
    }

    for (const button of document.querySelectorAll<HTMLButtonElement>('[data-line-type]')) {
      button.toggleAttribute(
        'data-active',
        Number(button.dataset.lineType) === this.game.tools.lineType,
      );
      button.disabled = !drawing;
    }

    const enable = (action: string, on: boolean): void => {
      query<HTMLButtonElement>(`[data-action="${action}"]`).disabled = !on;
    };

    enable('play', drawing && this.game.paths.length > 0);
    enable('stop', playing);
    enable('undo', drawing && this.game.paths.length > 0);
    enable('redo', drawing && this.game.paths.length > 0);
  }

  private renderSummary(): void {
    const list = query<HTMLElement>('[data-summary]');

    list.replaceChildren(
      ...this.game.summary.map(({ question, answer }) => {
        const item = document.createElement('li');
        item.innerHTML = `${escapeHtml(question)} <b>${escapeHtml(answer.replace(/-/g, ' '))}</b>`;
        return item;
      }),
    );
  }

  // --------------------------------------------------------------- dialogs

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

  /** Help and rider cards can be dismissed back to whatever was underneath. */
  private closeTransientDialog(): void {
    if (this.game.state === 'init') this.show('question');
    else this.hideOverlay();
  }
}

const escapeHtml = (value: string): string =>
  value.replace(
    /[&<>"']/g,
    (char) =>
      ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char] ?? char,
  );

export { TOOLS };
