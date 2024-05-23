import {ChangeDetectorRef, Component, OnDestroy} from '@angular/core';
import {ImageModule} from "primeng/image";
import {MediaMatcher} from "@angular/cdk/layout";

@Component({
  selector: 'app-chapter-configuration',
  standalone: true,
    imports: [
        ImageModule
    ],
  templateUrl: './chapter-configuration.component.html',
  styleUrl: './chapter-configuration.component.scss'
})
export class ChapterConfigurationComponent implements OnDestroy {
  mobileQuery: MediaQueryList;

  private readonly _mobileQueryListener: () => void;

  constructor(changeDetectorRef: ChangeDetectorRef, media: MediaMatcher) {
    this.mobileQuery = media.matchMedia('(max-width: 600px)');
    this._mobileQueryListener = () => changeDetectorRef.detectChanges();
    this.mobileQuery.addEventListener('change', this._mobileQueryListener);
  }

  protected get imageClass(): string {
    return this.mobileQuery.matches ? 'mobile-image' : 'float-left-image'
  }

  protected get imageWidth(): string {
    return this.mobileQuery.matches ? '120' : '240'
  }

  ngOnDestroy(): void {
    this.mobileQuery.removeEventListener('change', this._mobileQueryListener);
  }
}
