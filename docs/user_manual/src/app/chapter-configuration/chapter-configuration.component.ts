import {ChangeDetectorRef, Component, OnDestroy} from '@angular/core';
import {MediaMatcher} from "@angular/cdk/layout";
import {ImageThumbnailComponent} from "../image-viewer/image-thumbnail/image-thumbnail.component";

@Component({
  selector: 'app-chapter-configuration',
  standalone: true,
  imports: [
    ImageThumbnailComponent
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

  protected get screenshotContainerClass(): string {
    return this.mobileQuery.matches ? 'screenshots-container-mobile' : 'screenshots-container';
  }

  protected get imageClass(): string {
    return this.mobileQuery.matches ? 'thumbnail-mobile' : 'thumbnail'
  }

  ngOnDestroy(): void {
    this.mobileQuery.removeEventListener('change', this._mobileQueryListener);
  }
}
